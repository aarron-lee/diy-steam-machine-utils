#!/usr/bin/bash
#
# Credit to Bazzite devs: https://github.com/ublue-os/bazzite/blob/main/system_files/desktop/shared/usr/bin/cec-control
# Apache 2.0 license
#
# modified by aarron-lee for to work on SteamOS
#
ACTION="$1"

CEC_MODE=dgpu
CEC_TVID=0
CEC_WAKE=true
CEC_SETSOURCE=true
CEC_ONPOWEROFF_STANDBY=true
CEC_ONSLEEP_STANDBY=true

# OVERRIDE WITH DEFAULTS IF NOT SET
# CEC_TVID=${CEC_TVID:-0}
# CEC_WAKE=${CEC_WAKE:-true}
# CEC_SETSOURCE=${CEC_SETSOURCE:-true}
# CEC_ONPOWEROFF_STANDBY=${CEC_ONPOWEROFF_STANDBY:-true}
# CEC_ONSLEEP_STANDBY=${CEC_ONSLEEP_STANDBY:-false}

# Auto-detect which CEC backend to use
# If /dev/cec* exists -> kernel CEC (GPU native) -> use cec-ctl
USE_KERNEL_CEC=false
CEC_DEVICE=""

# Check for kernel CEC devices
for cec_dev in /dev/cec*; do
    if [[ -e "$cec_dev" ]]; then
        USE_KERNEL_CEC=true
        CEC_DEVICE="$cec_dev"
        break
    fi
done

if [ "$USE_KERNEL_CEC" = false ]; then
    echo "CEC not supported, exiting"
    exit 1
fi

args=()
args+=( "--single-command" )
args+=( "--log-level 1" )

# Conditionally apply a port number override if one is set
# [[ -n "$CEC_PORT_NUMBER" ]] && args+=( "--port $CEC_PORT_NUMBER" )

# Helper functions to send activate and standby messages to the CEC bus
# We loop through TVIDs to cover cases where you might have multiple devices
# to control (eg: a TV, an audio system, and some sort of tuner device)
function perform_standby {
    if [ "$USE_KERNEL_CEC" = true ]; then
        # Kernel CEC path
        cec-ctl -d "$CEC_DEVICE" --playback 2>/dev/null || true

        for id in $CEC_TVID; do
            cec-ctl -d "$CEC_DEVICE" --to "$id" --standby 2>/dev/null || \
                echo "Warning: Failed to send standby to CEC device $id" >&2

            #delay after sending standby command, to prevent the TV's Standby response
            #from being saved during the suspend process, and causing re-suspend on wake
            sleep 5
        done
    fi
}

function perform_activate {
    if [ "$USE_KERNEL_CEC" = true ]; then
        # Kernel CEC path
        cec-ctl -d "$CEC_DEVICE" --playback 2>/dev/null || true

        for id in $CEC_TVID; do
            cec-ctl -d "$CEC_DEVICE" --to "$id" --image-view-on 2>/dev/null || \
                echo "Warning: Failed to send image-view-on to CEC device $id" >&2
        done

        if [ "$CEC_SETSOURCE" = true ]; then
            # Add a short delay so that the CEC device has time to acknowledge this command
            sleep 0.1
            # Get our physical address if we are setting source
            local phys_addr=$(cec-ctl -d "$CEC_DEVICE" 2>/dev/null | grep "Physical Address" | awk '{print $4}')
            if [[ -n "$phys_addr" ]]; then
                cec-ctl -d "$CEC_DEVICE" -s --active-source phys-addr="$phys_addr" 2>/dev/null || true
            fi
        fi
    fi
}

# Run specified actions
if [ "${ACTION}" = "onboot" ] && [ "$CEC_WAKE" = true ]; then
    perform_activate
elif [ "${ACTION}" = "onpoweroff" ] && [ "$CEC_ONPOWEROFF_STANDBY" = true ]; then
    perform_standby
elif [ "${ACTION}" = "onsleep" ] && [ "$CEC_ONSLEEP_STANDBY" = true ]; then
    perform_standby
fi
