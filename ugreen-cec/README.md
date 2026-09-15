# Ugreen Displayport to HDMI adapter - Enable CEC via dGPU

Credit to Bazzite (and related devs) for cec implementation

Source: https://github.com/ublue-os/bazzite/blob/main/system_files/desktop/shared/usr/bin/cec-control

Modified by aarron-lee to work on SteamOS

# Requirements

Intended to be used with a [UGREEN DisplayPort-to-HDMI adapter with HDMI-CEC support](https://www.amazon.com/dp/B0FQCGSWW3)

Note that you may need to [update the firmware for the adapter](https://github.com/ublue-os/bazzite/issues/4532#issuecomment-4951856963) before use.

# Install instructions

run the following in terminal:

```bash
curl -L https://raw.githubusercontent.com/aarron-lee/diy-steam-machine-utils/main/ugreen-cec/install.sh | sh
```

# Uninstall instructions

run the following in terminal:

```bash
curl -L https://raw.githubusercontent.com/aarron-lee/diy-steam-machine-utils/main/ugreen-cec/uninstall.sh | sh
```
