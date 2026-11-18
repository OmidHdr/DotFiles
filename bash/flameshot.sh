#!/usr/bin/bash

if [[ ${XDG_SESSION_TYPE:-} == x11 && -n ${DISPLAY:-} ]]; then
    export QT_QPA_PLATFORM=xcb QT_XCB_NO_XRANDR=1 QT_SCALE_FACTOR=1
    exec python3 "$(dirname -- "${BASH_SOURCE[0]}")/flameshot-x11.py" "$@"
fi
exec /usr/bin/flameshot gui "$@"
