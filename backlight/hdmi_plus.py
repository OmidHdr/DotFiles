import os

os.chdir("/home/h0p3/.config/backlight")
f = open("config.txt", "r")
result = float(f.read()) + 0.3

print(result)

os.system("xrandr --output HDMI-1 --brightness " + str(result))
os.system("rm config.txt")

with open('config.txt', 'w') as x:
    x.write(str(result))
    x.close()
