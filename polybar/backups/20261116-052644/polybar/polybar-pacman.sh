#!/bin/bash

check() {
	count=$(checkupdates 2>/dev/null | wc -l)
	if [ "$count" -gt 0 ]; then
		echo "Repo : $count"
	else
		echo "Up to date"
	fi
}

if [ "$1" = "update" ]; then
	setsid bash -c '
        export DISPLAY=:0
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
        
        # استفاده از pkexec برای باز شدن پنجره گرافیکی دریافت رمز
        if pkexec pacman -Syu --noconfirm > /tmp/pacman-update.log 2>&1; then
            notify-send "Pacman" "سیستم با موفقیت به‌روزرسانی شد."
        else
            notify-send "Pacman" "خطا در به‌روزرسانی سیستم! فایل لاگ را بررسی کنید."
        fi
    ' &
	exit 0
fi

check
