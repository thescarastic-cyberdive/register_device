#!/bin/bash

# Retrieve IMEI, device model, and serial number using adb
DEVICE=$(adb shell "getprop ro.product.model")
IMEI=$(adb shell "service call iphonesubinfo 1 s16 com.android.shell | cut -c 50-64 | tr -d '.[:space:]'")
SERIAL=$(adb shell "getprop ro.serialno")

# Check if the variables are not empty
if [[ -z "$DEVICE" || -z "$IMEI" || -z "$SERIAL" ]]; then
  echo "Error: Could not retrieve device information."
  exit 1
fi

# Send data using curl
curl --location 'https://alpha.fffink.com/internal/customer/v1/onboarding/register/device' \
--header 'Content-Type: application/json' \
--data '{
    "serialNumber": "'"$SERIAL"'",
    "imei": "'"$IMEI"'",
    "deviceModel": "'"$DEVICE"'"
}'
