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

# Get Auth token for official API
ACCESS_TOKEN=$(curl --location 'https://cyberdive.auth.us-west-2.amazoncognito.com/oauth2/token/' \
  --header 'Authorization: Basic NW8xbmxiZmtwM29lZjc5ZjBsdTNtYnNhbTQ6ZWttczE1bWk2N3Zoa2ZwYXJxN2NwZWI4bWdpM2c1Y3AyYjRxZXY0NWVvNnR1djZ2aG1t' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=client_credentials' \
  --data-urlencode 'scope=userService/allAPIs' | awk -F'"' '/access_token/{print $4}')

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Error: Access token is missing or empty."
  exit 1
fi

# Send data using curl
curl --location 'https://api.cyberdive.co/customer/v1/onboarding/register/device' \
  --header "Authorization: $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  --data '{
    "serialNumber": "'"$SERIAL"'",
    "imei": "'"$IMEI"'",
    "deviceModel": "'"$DEVICE"'"
}'

# Reboot to bootloader
adb reboot bootloader

# Fastboot unlock bootloader
fastboot flashing unlock

# Fastboot flash the builds
export ANDROID_PRODUCT_OUT=`pwd`
fastboot flashall -w --disable-verity --disable-verification
