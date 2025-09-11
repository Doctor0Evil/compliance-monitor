#!/bin/bash
# nanoswarm-hardware-guard.sh

WATCHDOG=/dev/hw_watchdog
TEMP_SENSOR=/dev/hw_temp
POWER_STATUS=/dev/hw_power
ERR_FLAG=/dev/hw_ecc
HALT_SWITCH=/dev/hw_halt

read_temp() { cat "$TEMP_SENSOR"; }
read_power() { cat "$POWER_STATUS"; }
read_watchdog() { cat "$WATCHDOG"; }
read_error() { cat "$ERR_FLAG"; }

if [[ "$(read_power)" != "OK" ]] || [[ -f "$HALT_SWITCH" ]]; then
    echo "CRITICAL: Power or halt switch triggered—IMMEDIATE HALT."
    exit 100
fi

if [[ "$(read_temp)" > "80" ]]; then
    echo "WARNING: Physical device overheated. Pausing script execution."
    while [[ "$(read_temp)" > "75" ]]; do sleep 5; done
    echo "Temperature normalized, resuming..."
fi

if [[ "$(read_error)" == "1" ]]; then
    echo "ERROR: ECC detection. Halting script for operator intervention."
    exit 101
fi

# Continue only with all-clear hardware signals
echo "All hardware signals safe — continuing workflow..."
