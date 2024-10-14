import os

try:
    os.system('killall simple-mtpfs')
except Exception:
    os.system('simple-mtpfs -o nonempty ~/myphone')
    print("not fount") 

os.system('simple-mtpfs -o nonempty ~/myphone')

