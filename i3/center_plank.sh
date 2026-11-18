#!/usr/bin/env bash

# Let the compositor and monitor layout settle before starting the dock.
sleep 2
if ! pgrep -u "$(id -u)" -x plank >/dev/null; then
    /usr/bin/plank >/tmp/plank.log 2>&1 &
fi

exec python3 "$(dirname -- "${BASH_SOURCE[0]}")/plank-reservation.py"
