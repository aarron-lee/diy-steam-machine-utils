#!/usr/bin/bash

if [ "$(id -u)" -eq 0 ]; then
    echo "This script must not be run as root. don't use sudo" >&2
    exit 1
fi

CONF_DIR="/etc/atomic-update.conf.d/"
SERVICE_NAME="gpp-disable.service"
GPP_DISABLE_SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

sudo systemctl disable --now $SERVICE_NAME

sudo rm -f $GPP_DISABLE_SERVICE_PATH

sudo rm $CONF_DIR/gpp-disable-keep-list.conf

echo "uninstall complete!"
