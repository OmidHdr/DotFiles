#!/bin/bash
#!/bin/bash

if [[ -z "$2" ]]; then
    exit 1
fi

player="$1"

case "$player" in
    "mpv") mpv "$2" ;;
    "vlc") vlc "$2" ;;
    *) exit 1 ;;
esac
