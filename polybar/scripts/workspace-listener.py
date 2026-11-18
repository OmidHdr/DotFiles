#!/usr/bin/env python3
"""i3 IPC events resize only the affected left capsule, under the launch lock."""
import fcntl,json,os,select,signal,socket,struct,subprocess,time,threading
from pathlib import Path
BASE=Path.home()/'.config/polybar'
STATE=Path(os.environ.get('XDG_STATE_HOME',str(Path.home()/'.local/state')))/'polybar-menu'
CACHE=Path(os.environ.get('XDG_CACHE_HOME',str(Path.home()/'.cache')))/'polybar-menu'
STATE.mkdir(parents=True,exist_ok=True)
lock=open(STATE/'monitors.lock','w')
try: fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
except BlockingIOError: raise SystemExit(0)
(STATE/'watcher.pid').write_text(str(os.getpid()))
def run(*args): return subprocess.check_output(args,text=True).strip()
def resize():
 with open(STATE/'control.lock','w') as control:
  fcntl.flock(control,fcntl.LOCK_EX)
  for pf in CACHE.glob('*-left.pid'):
   try:
    pid=int(pf.read_text());cmd=Path(f'/proc/{pid}/cmdline').read_bytes().split(b'\0')
    if cmd[:3] != [b'polybar',b'-c',str(BASE/'config.ini').encode()] or b'left' not in cmd: continue
    env=dict(v.decode().split('=',1) for v in Path(f'/proc/{pid}/environ').read_bytes().split(b'\0') if b'=' in v)
    monitor=env['MONITOR']; dpi=int(env.get('BAR_DPI','96'))
    required=int(run('python3',str(BASE/'scripts/left-width.py'),monitor,str(dpi)))
    maximum=int(env['CENTER_X'])-int(env['LEFT_X'])-16*dpi//96
    required=min(required,maximum)
    if int(env['LEFT_WIDTH'])==required: continue
    env['LEFT_WIDTH']=str(required)
    os.kill(pid,signal.SIGTERM)
    for _ in range(40):
     if not Path(f'/proc/{pid}').exists(): break
     time.sleep(.025)
    with open(CACHE/f'{monitor}-left.log','w') as log:
     child=subprocess.Popen(['polybar','-c',str(BASE/'config.ini'),'left'],env=env,stdin=subprocess.DEVNULL,stdout=log,stderr=log,start_new_session=True,close_fds=True)
    threading.Thread(target=child.wait,daemon=True).start()
    pf.write_text(str(child.pid))
    (CACHE/'pids').write_text(''.join(f.read_text().strip()+'\n' for f in sorted(CACHE.glob('*-*.pid'))))
    print(f'{monitor}: width {required}px; left {pid} -> {child.pid}',flush=True)
   except (FileNotFoundError,ProcessLookupError,KeyError,ValueError): continue
def receive(s):
 def exact(n):
  data=b''
  while len(data)<n:
   block=s.recv(n-len(data))
   if not block: raise ConnectionError('i3 IPC closed')
   data+=block
  return data
 header=exact(14)
 if header[:6]!=b'i3-ipc': raise ConnectionError('Bad IPC header')
 length,typ=struct.unpack('=II',header[6:]);return typ,json.loads(exact(length))
monitors=run('polybar','--list-monitors')
while True:
 try:
  with socket.socket(socket.AF_UNIX) as s:
   s.connect(run('i3','--get-socketpath'))
   payload=b'["workspace","output"]';s.sendall(b'i3-ipc'+struct.pack('=II',len(payload),2)+payload)
   typ,answer=receive(s)
   if not answer.get('success'): raise ConnectionError('Subscription rejected')
   resize()
   while True:
    typ,event=receive(s)
    if typ==0x80000001:
     current=run('polybar','--list-monitors')
     if current!=monitors:
      subprocess.run([str(BASE/'scripts/launch.sh')],check=True);monitors=current
    elif typ==0x80000000 and event.get('change') in ('init','empty','move','rename'):
     # Coalesce the init/focus/empty burst, without polling i3 continuously.
     time.sleep(.12)
     resize()
 except (OSError,ConnectionError,subprocess.CalledProcessError) as e:
  print(f'IPC reconnect: {type(e).__name__}',flush=True);time.sleep(2)
