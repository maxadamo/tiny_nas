#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if ! pgrep -f lsyncd; then
  systemctl restart lsyncd.service
done

until pgrep -f lsyncd; do
  systemctl restart lsyncd.service
done

systemctl reload nfs-server.service