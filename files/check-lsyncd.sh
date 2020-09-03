#!/bin/bash
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

if ip add sh | grep -q secondary; then
    pgrep -f lsyncd &>/dev/null || systemctl start lsyncd.service
else
    pgrep -f lsyncd &>/dev/null && systemctl stop lsyncd.service
fi
