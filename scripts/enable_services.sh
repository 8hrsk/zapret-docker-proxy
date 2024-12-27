#!/bin/bash

systemctl stop systemd-resolved

systemctl enable dnscrypt-proxy.service
systemctl start dnscrypt-proxy.service
systemctl enable systemd-resolved.service
systemctl start systemd-resolved.service

exit 0