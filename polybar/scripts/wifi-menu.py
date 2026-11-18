#!/usr/bin/env python3
"""NetworkManager Wi-Fi menu. SSIDs are data; secrets travel only over a PTY."""
import fcntl,json,os,pty,re,select,subprocess,sys,termios,time,uuid
from pathlib import Path
# Polybar supplies the X11 session environment. Fill only missing values from
# the launching process's ancestors, never from another user's/session's process.
for key in ('DISPLAY','XAUTHORITY','DBUS_SESSION_BUS_ADDRESS'):
 if os.environ.get(key):continue
 pid=os.getppid()
 while pid>1:
  try:
   proc=Path(f'/proc/{pid}')
   if proc.stat().st_uid!=os.getuid():break
   values=dict(item.split('=',1) for item in (proc/'environ').read_text().split('\0') if '=' in item)
   if values.get(key):os.environ[key]=values[key];break
   pid=int((proc/'stat').read_text().rsplit(')',1)[1].split()[1])
  except (OSError,ValueError):break
if not os.environ.get('DBUS_SESSION_BUS_ADDRESS'):
 bus=Path(f'/run/user/{os.getuid()}/bus')
 if bus.exists():os.environ['DBUS_SESSION_BUS_ADDRESS']=f'unix:path={bus}'
ENV=os.environ|{'LC_ALL':'C.UTF-8','LANG':'C.UTF-8','NO_COLOR':'1','PAGER':''}
class NetworkError(Exception):pass
def nm(*args):
 try:
  p=subprocess.run(['nmcli','--colors','no',*args],env=ENV,text=True,capture_output=True,timeout=15)
  if p.returncode:raise NetworkError(clean(p.stderr.strip() or f'NetworkManager command failed ({p.returncode})'))
  return p.stdout.rstrip('\n')
 except subprocess.TimeoutExpired:raise NetworkError('NetworkManager did not respond within 15 seconds.')
 except FileNotFoundError:raise NetworkError('nmcli is not installed.')
def fields(line):
 result=[];field='';escape=False
 for c in line:
  if escape:field+=c;escape=False
  elif c=='\\':escape=True
  elif c==':':result.append(field);field=''
  else:field+=c
 result.append(field);return result

def clean(s):return ''.join(c if c.isprintable() else ' ' for c in s)
def theme():
 state=Path(os.environ.get('XDG_STATE_HOME',str(Path.home()/'.local/state')))/'polybar-menu/theme'
 dark=state.exists() and state.read_text().strip()=='dark'
 bg,fg,selected=('#17191F','#F5F5F7','#293E59') if dark else ('#F2F2F7','#1D1D1F','#D8E8FA')
 return f'''* {{ background-color: {bg}; text-color: {fg}; font: "SF Pro Display 11"; }}
 window {{ width: 620px; border: 0; border-radius: 16px; padding: 14px; }}
 mainbox {{ children: [inputbar, listview]; spacing: 10px; }}
 inputbar {{ children: [prompt, entry]; spacing: 10px; padding: 5px; }}
 listview {{ lines: 12; scrollbar: false; }}
 element {{ padding: 9px; border-radius: 8px; }}
 window, mainbox, inputbar, listview {{ background-color: {bg}; border: 0px; }}
 element normal.normal, element alternate.normal {{ background-color: {bg}; text-color: {fg}; }}
 element normal.active, element alternate.active {{ background-color: {selected}; text-color: {fg}; }}
 element selected.normal, element selected.active {{ background-color: {selected}; text-color: {fg}; }}
 element-text, element-icon {{ background-color: inherit; text-color: inherit; }}
 prompt, entry {{ background-color: {bg}; text-color: {fg}; }}
 entry {{ placeholder-color: {fg}; }}'''
def rofi(prompt,rows=None,password=False,active=None):
 args=['rofi','-no-config','-dmenu','-i','-disable-history','-no-markup-rows','-p',prompt,'-theme-str',theme()]
 if rows is not None:args+=['-format','i','-no-custom']
 if active:args+=['-a',','.join(map(str,active))]
 if password:args+=['-password','-theme-str', 'listview { lines: 0; }']
 p=subprocess.run(args,input='\n'.join(map(clean,rows)) if rows is not None else '',text=True,capture_output=True)
 if p.returncode not in (0,1):
  # Never write Rofi output (which can contain a credential) to a log.
  print('Wi-Fi: Rofi failed to open; check DISPLAY/XAUTHORITY and Rofi installation.',file=sys.stderr)
 if p.returncode!=0:return None
 return p.stdout.rstrip('\n')
def choose(prompt,rows,active=None):
 result=rofi(prompt,rows,active=active)
 if result is None:return None
 try:
  index=int(result)
  return index if 0<=index<len(rows) else None
 except ValueError:return None
def notify(message):
 # A Rofi error stays visible even if no desktop notification daemon is running.
 rofi('Wi-Fi', [clean(message),'Close'])
def adapters():
 return [p for line in nm('-t','-f','DEVICE,TYPE,STATE','device','status').splitlines() if len(p:=fields(line))==3 and p[1]=='wifi']
def saved():
 profiles=[]
 for line in nm('-t','-f','UUID,TYPE,NAME','connection','show').splitlines():
  row=fields(line)
  if len(row)!=3 or row[1]!='802-11-wireless':continue
  uuid,_,name=row
  ssid=nm('--escape','no','-g','802-11-wireless.ssid','connection','show','uuid',uuid)
  profiles.append({'uuid':uuid,'name':name,'ssid':ssid})
 return profiles
def networks(interface):
 rows=[]
 data=nm('-t','-f','IN-USE,SSID,SIGNAL,SECURITY,BSSID','device','wifi','list','ifname',interface,'--rescan','no')
 # Prefer the active BSSID when several access points advertise one SSID.
 lines=sorted(data.splitlines(),key=lambda line:not line.startswith('*:'))
 seen=set()
 for line in lines:
  row=fields(line)
  if len(row)!=5:continue
  active,ssid,signal,security,bssid=row
  if not ssid or ssid in seen:continue
  seen.add(ssid)
  rows.append({'active':active.strip()=='*','ssid':ssid,'signal':signal,'security':security,'bssid':bssid})
 return rows

def ask_nm(args):
 # --ask avoids putting a Wi-Fi secret in argv, environment, files, or logs.
 # Child tty echo is disabled before nmcli starts. Output is never persisted/shown.
 master,slave=pty.openpty()
 attrs=termios.tcgetattr(slave);attrs[3]&=~(termios.ECHO|termios.ECHONL);termios.tcsetattr(slave,termios.TCSANOW,attrs)
 process=subprocess.Popen(['nmcli','--colors','no','--ask','--wait','75',*args],env=ENV,stdin=slave,stdout=slave,stderr=slave,close_fds=True,start_new_session=True)
 os.close(slave);buffer='';deadline=time.monotonic()+100;cancelled=False;timed_out=False
 try:
  while process.poll() is None and time.monotonic()<deadline:
   if select.select([master],[],[],.2)[0]:
    try:block=os.read(master,8192)
    except OSError:break
    if not block:break
    buffer=(buffer+block.decode('utf-8','replace'))[-8192:]
    # nmcli interactive prompts end in ':'. Only prompt for actual input requests.
    last=buffer.rsplit('\n',1)[-1]
    if re.search(r'(password|passphrase|secret|username|identity|pin|wep key).*[:?]\s*$',last,re.I):
     value=rofi('Network credential',password=True)
     if value is None:
      cancelled=True;process.terminate();break
     # Reassert no echo in case the interactive client changed tty flags.
     attrs=termios.tcgetattr(master);attrs[3]&=~(termios.ECHO|termios.ECHONL)
     termios.tcsetattr(master,termios.TCSANOW,attrs)
     os.write(master,value.encode('utf-8')+b'\n');value=None;buffer=''
  if process.poll() is None:
   timed_out=not cancelled;process.terminate()
  try:code=process.wait(timeout=4)
  except subprocess.TimeoutExpired:
   process.kill();code=process.wait()
  if cancelled:return None
  if code==0:return True
  # Never surface PTY output: it may contain credentials from an interactive
  # agent. Device reason is a separate, non-secret NetworkManager property.
  interface=args[args.index('ifname')+1] if 'ifname' in args else None
  reason=nm('-g','GENERAL.STATE,GENERAL.REASON','device','show',interface) if interface else ''
  notify(('Connection timed out.' if timed_out else f'Connection failed (nmcli exit {code}).')+' '+reason.replace('\n',' · '))
  return False
 finally:
  os.close(master)
  if process.poll() is None:process.kill();process.wait()

def connect(interface,ap):
 matches=[p for p in saved() if p['ssid']==ap['ssid']]
 if matches:
  index=0 if len(matches)==1 else choose('Saved profile',[p['name'] for p in matches])
  if index is None:return
  args=['connection','up','uuid',matches[index]['uuid'],'ifname',interface,'ap',ap['bssid']]
 else:
  if '802.1X' in ap['security'] or 'WPA-EAP' in ap['security']:
   notify('Enterprise Wi-Fi needs a preconfigured NetworkManager profile.');return
  # BSSID is a validated MAC, so leading-dash or unusual SSIDs never become options.
  if not re.fullmatch(r'(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}',ap['bssid']):return
  # Create a credential-free profile first. NOT_SAVED (2) prevents new
  # personal Wi-Fi passwords being written to NetworkManager keyfiles.
  identifier=str(uuid.uuid4())
  security=ap['security'].upper()
  settings=[]
  if 'WPA' in security:
   method='sae' if 'WPA3' in security and 'WPA2' not in security else 'wpa-psk'
   settings=['wifi-sec.key-mgmt',method,'wifi-sec.psk-flags','2']
  elif 'WEP' in security:
   settings=['wifi-sec.key-mgmt','none','wifi-sec.wep-key-flags','2']
  elif 'OWE' in security:settings=['wifi-sec.key-mgmt','owe']
  elif security not in ('','--'):
   notify('Unsupported Wi-Fi security; configure a saved NetworkManager profile first.');return
  nm('connection','add','type','wifi','ifname',interface,
    'con-name',ap['ssid'],'ssid',ap['ssid'],'connection.uuid',identifier,
    'connection.autoconnect','no',*settings)
  args=['connection','up','uuid',identifier,'ifname',interface,'ap',ap['bssid']]
 if ask_nm(args):notify('Connection activated.')

def main():
 if '--list' in sys.argv:
  for interface,_,state in adapters():
   print(json.dumps({'interface':interface,'state':state,'networks':networks(interface)},ensure_ascii=False))
  return
 state=Path(os.environ.get('XDG_RUNTIME_DIR',str(Path.home()/'.cache')))/'polybar-wifi-menu.lock'
 lock=open(state,'w')
 try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 except BlockingIOError:return
 choices=adapters()
 if not choices:rofi('Wi-Fi',['No Wi-Fi adapter available']);return
 index=0 if len(choices)==1 else choose('Wi-Fi adapter',[p[0] for p in choices])
 if index is None:return
 interface=choices[index][0]
 while True:
  if nm('-g','GENERAL.NM-MANAGED','device','show',interface)!='yes':
   details=nm('-g','GENERAL.STATE,GENERAL.REASON','device','show',interface)
   services=subprocess.run(['systemctl','list-units','--type=service','--state=running','--no-legend','--no-pager'],capture_output=True,text=True)
   managers=[line.split()[0] for line in services.stdout.splitlines() if any(name in line.split()[0] for name in ('NetworkManager','iwd','wpa_supplicant','connman','systemd-networkd'))]
   rofi('Wi-Fi',[f'{interface} is not managed by NetworkManager',*details.splitlines(),'Running network services: '+', '.join(managers),'No services or connections were changed']);return
  radio=nm('radio','wifi')
  if radio!='enabled':
   index=choose('Wi-Fi disabled',['Enable Wi-Fi','Close'])
   if index==0:
    nm('radio','wifi','on')
    continue
   return
  aps=networks(interface)
  state=nm('-g','GENERAL.STATE','device','show',interface)
  rows=[f'{"● " if a["active"] else "  "}{a["ssid"]}   {a["signal"]}%   {a["security"] or "Open"}' for a in aps]
  actions=['Refresh network list','Saved connections']
  if state.startswith('100'):actions.append('Disconnect Wi-Fi')
  actions+=['Disable Wi-Fi','Close']
  if not rows:rows=['No visible networks — choose Refresh'];aps=[None]
  choice=choose('Wi-Fi · '+interface,rows+actions,active=[i for i,a in enumerate(aps) if a and a['active']])
  if choice is None:return
  if choice<len(aps):
   if aps[choice]:connect(interface,aps[choice])
   continue
  action=actions[choice-len(aps)]
  if action=='Refresh network list':nm('device','wifi','rescan','ifname',interface)
  elif action=='Saved connections':
   profiles=saved();selected=choose('Saved Wi-Fi',[p['name'] for p in profiles]) if profiles else None
   if selected is not None:
    ok=ask_nm(['connection','up','uuid',profiles[selected]['uuid'],'ifname',interface])
    if ok:notify('Connection activated.')
  elif action=='Disconnect Wi-Fi':
   if choose('Disconnect Wi-Fi?',['Cancel','Disconnect'])==1:nm('device','disconnect',interface)
  elif action=='Disable Wi-Fi':
   if choose('Disable Wi-Fi?',['Cancel','Disable'])==1:nm('radio','wifi','off')
  else:return
if __name__=='__main__':
 try:main()
 except NetworkError as error:notify(str(error))
 except FileNotFoundError as error:
  print(f'Wi-Fi: required program not found: {error.filename}',file=sys.stderr)
