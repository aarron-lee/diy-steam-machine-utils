#!/usr/bin/bash

if [ "$(id -u)" -eq 0 ]; then
    echo "This script must not be run as root. don't use sudo" >&2
    exit 1
fi

echo "Credit to Bazzite devs: https://github.com/ublue-os/bazzite/blob/main/system_files/desktop/shared/usr/bin/cec-control"

CEC_CONTROL_DIR="$HOME/.local/bin"
CEC_BIN="$CEC_CONTROL_DIR/cec-control"
CONF_DIR="/etc/atomic-update.conf.d/"

services=("cec-onboot" "cec-onpowerff" "cec-onsleep")

for service in "${services[@]}"; do
    sudo systemctl disable --now "$service"
    sudo rm -f "/etc/systemd/system/$service"
done

rm -f $CEC_BIN

sudo rm -f $CONF_DIR/cec-control.conf

echo "uninstall complete!"
