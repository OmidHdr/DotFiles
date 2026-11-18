#!/usr/bin/env python3
"""Make transparent reservation docks accept no mouse input (X Shape extension)."""
import ctypes as C
import subprocess
import time
x = C.CDLL('libX11.so.6'); ext = C.CDLL('libXext.so.6')
x.XOpenDisplay.argtypes = [C.c_char_p]; x.XOpenDisplay.restype = C.c_void_p
x.XQueryTree.argtypes = [C.c_void_p, C.c_ulong, C.POINTER(C.c_ulong), C.POINTER(C.c_ulong), C.POINTER(C.POINTER(C.c_ulong)), C.POINTER(C.c_uint)]
x.XFree.argtypes = [C.c_void_p]
x.XFlush.argtypes = [C.c_void_p]; x.XCloseDisplay.argtypes = [C.c_void_p]
ext.XShapeCombineRectangles.argtypes = [C.c_void_p, C.c_ulong, C.c_int, C.c_int, C.c_int, C.c_void_p, C.c_int, C.c_int, C.c_int]
d = x.XOpenDisplay(None)
if not d: raise SystemExit('Cannot open X display')
for attempt in range(10):
 result = subprocess.run(['xdotool', 'search', '--name', '^polybar-reserve_'], capture_output=True, text=True)
 if result.stdout.strip():
  for wid in result.stdout.split():
   window = int(wid)
   ext.XShapeCombineRectangles(d, window, 2, 0, 0, None, 0, 0, 0)
   root=C.c_ulong(); parent=C.c_ulong(); children=C.POINTER(C.c_ulong)(); count=C.c_uint()
   x.XQueryTree(d, window, C.byref(root), C.byref(parent), C.byref(children), C.byref(count))
   if children: x.XFree(children)
   if parent.value and parent.value != root.value:
    ext.XShapeCombineRectangles(d, parent.value, 2, 0, 0, None, 0, 0, 0)
  x.XFlush(d)
 time.sleep(.1)
x.XCloseDisplay(d)
