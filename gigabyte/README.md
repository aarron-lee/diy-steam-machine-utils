# Gigabyte motherboard suspend-resume workaround

Credit to https://blog.rxbrad.com/fixing-sleep-issues-with-bazzite-on-a-gigabyte-motherboard/ for workaround

# Install instructions

run the following in terminal:

```bash
curl -L https://raw.githubusercontent.com/aarron-lee/diy-steam-machine-utils/main/gigabyte/install.sh | sh
```

Afterwards, if you run `cat /proc/acpi/wakeup | grep GPP` in terminal, it should show that GPP0 and GPP8 are disabled

# Uninstall instructions

run the following in terminal:

```bash
curl -L https://raw.githubusercontent.com/aarron-lee/diy-steam-machine-utils/main/gigabyte/uninstall.sh | sh
```
