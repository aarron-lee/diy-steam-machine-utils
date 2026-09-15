#!/usr/bin/bash

if [ "$(id -u)" -eq 0 ]; then
    echo "This script must not be run as root. don't use sudo" >&2
    exit 1
fi

echo "Credit to Bazzite devs: https://github.com/ublue-os/bazzite/blob/main/system_files/desktop/shared/usr/bin/cec-control"

USE_KERNEL_CEC=false

# Check for kernel CEC devices
for cec_dev in /dev/cec*; do
    if [[ -e "$cec_dev" ]]; then
        USE_KERNEL_CEC=true
        break
    fi
done

if [ "$USE_KERNEL_CEC" = false ]; then
    echo "CEC device not detected, exiting"
    exit 1
fi

echo "Downloading required files..."

cd /tmp

git clone --depth=1 https://github.com/aarron-lee/diy-steam-machine-utils.git

cd diy-steam-machine-utils/ugreen-cec

CONF_DIR="/etc/atomic-update.conf.d/"
CEC_CONTROL_DIR="$HOME/.local/bin"
CEC_BIN="$CEC_CONTROL_DIR/cec-control"

if [ -d "$CEC_CONTROL_DIR" ]; then
    echo "$CEC_CONTROL_DIR conf dir exists"
else
    echo "$CEC_CONTROL_DIR dir missing, make $CEC_CONTROL_DIR"
    mkdir -p $CEC_CONTROL_DIR
fi

if [ -d "$CONF_DIR" ]; then
    echo "atomic-update conf dir exists"
else
    echo "atomic-update conf dir missing, make $CONF_DIR"
    sudo mkdir -p $CONF_DIR
fi

if [ -d "$CEC_CONTROL_DIR" ] && [ -d "$CONF_DIR" ] && [ -d "/etc/systemd/system/" ]; then
    echo "All required directories exist."
else
    echo "One or more directories are missing."
    exit 1
fi

prompt_options() {
  local -n _result_array=$1

  _result_array=()

  local questions=(
    "Do you want CEC to turn on your TV on boot?"
    "Do you want CEC to turn off your TV on power off?"
    "Do you want CEC to turn on/off your TV on sleep/wake?"
  )
  local values=(
    "cec-onboot"
    "cec-onpoweroff"
    "cec-onsleep"
  )

  # Ordered loop through array indices
  for i in "${!questions[@]}"; do
    local question="${questions[i]}"
    local value="${values[i]}"

    while true; do
      read -p "$question (y/n): " answer
      case "$answer" in
        [Yy]* )
          _result_array+=("$value")
          break
          ;;
        [Nn]* )
          break
          ;;
        * )
          echo "Please answer y or n."
          ;;
      esac
    done
  done
}

services=()

prompt_options services

# services=("cec-onboot" "cec-onpoweroff" "cec-onsleep")

echo "----------------------------"
echo "Removing old versions for cec, assuming it was previously installed"
echo "Note: You can ignore any error messages until the INSTALL step"
echo "----------------------------"

allServices=("cec-onboot" "cec-onpoweroff" "cec-onsleep")

for s in "${allServices[@]}"; do
    # cleanup any old prior services
    sudo systemctl disable --now "$s"
    sudo rm -f "/etc/systemd/system/$s.service"
done

rm -f $CEC_BIN

echo "----------------------------"
echo "INSTALL starting - cec-control + onbook/onpoweroff/onsleep services"
echo "----------------------------"

cp ./cec-control.sh $CEC_BIN
chmod +x $CEC_BIN

for service in "${services[@]}"; do
    SERVICE_FILE_NAME="$service.service"
    sudo cp ./$SERVICE_FILE_NAME /etc/systemd/system

    sudo systemctl daemon-reload
    sudo systemctl enable --now $SERVICE_FILE_NAME
done

sudo cp ./cec-control.conf $CONF_DIR

echo "Cleanup downloaded files"

rm -rf /tmp/diy-steam-machine-utils

echo "installation complete!"
