#!/bin/bash


systemctl stop systemd-resolved

# systemctl restart dnsmasq.service
systemctl enable dnscrypt-proxy.service
systemctl start dnscrypt-proxy.service
systemctl enable systemd-resolved.service
systemctl start systemd-resolved.service
systemctl restart squid

echo "services enabled and started"

exit 0