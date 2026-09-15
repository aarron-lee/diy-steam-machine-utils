#!/usr/bin/bash

if [ "$(id -u)" -eq 0 ]; then
    echo "This script must not be run as root. don't use sudo" >&2
    exit 1
fi

echo "Downloading required files..."

cd /tmp

git clone --depth=1 https://github.com/aarron-lee/diy-steam-machine-utils.git

cd diy-steam-machine-utils/gigabyte

CONF_DIR="/etc/atomic-update.conf.d/"

if [ -d "$CONF_DIR" ]; then
    echo "atomic-update conf dir exists"
else
    echo "conf dir missing, make $CONF_DIR"
    sudo mkdir -p $CONF_DIR
fi

if [ -d "$CONF_DIR" ] && [ -d "/etc/systemd/system/" ]; then
    echo "Both required directories exist."
else
    echo "One or both directories are missing."
    exit 1
fi

SERVICE_NAME="gpp-disable.service"
GPP_DISABLE_SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

echo "----------------------------"
echo "Removing old versions of this workaround, assuming it was previously installed"
echo "Note: You can ignore any error messages until the INSTALL step"
echo "----------------------------"

sudo systemctl disable --now $SERVICE_NAME

sudo rm -f $GPP_DISABLE_SERVICE_PATH

# end disabling of legacy version of fix

echo "----------------------------"
echo "INSTALL starting - Gigabyte suspend fix"
echo "----------------------------"

sudo cp ./$SERVICE_NAME /etc/systemd/system

sudo systemctl daemon-reload
sudo systemctl enable --now $SERVICE_NAME

sudo cp ./gpp-disable-keep-list.conf $CONF_DIR

echo "Cleanup downloaded files"

rm -rf /tmp/diy-steam-machine-utils

echo "installation complete!"
