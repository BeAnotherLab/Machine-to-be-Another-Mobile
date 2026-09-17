#!/bin/bash

CONTENT="."
TMP="/data/local/tmp/Content"
PERSISTENT="/storage/emulated/0/Android/data/com.BeAnotherLab.MachineToBeAnother/files/Content"
ADB="/opt/homebrew/bin/adb"

# Get the name of this script so it doesn't copy itself
SCRIPT_NAME="$(basename "$0")"

# Check ADB
"$ADB" devices

# Clear and recreate temporary content directory
"$ADB" shell rm -rf "$TMP"
"$ADB" shell mkdir -p "$TMP"

# Copy files, excluding:
# - .DS_Store
# - this script
# - the Windows PowerShell version
echo "Copying files..."

find "$CONTENT" -maxdepth 1 -type f \
    ! -name ".DS_Store" \
    ! -name "$SCRIPT_NAME" \
    ! -name "push-content.ps1" \
    -exec "$ADB" push "{}" "$TMP/" \;

# Copy directories
find "$CONTENT" -mindepth 1 -maxdepth 1 -type d \
    -exec "$ADB" push "{}" "$TMP/" \;

# Copy to persistent application storage
echo "Copying content to persistent application storage..."

"$ADB" shell rm -rf "$PERSISTENT"
"$ADB" shell mkdir -p "$PERSISTENT"
"$ADB" shell cp -r "$TMP/." "$PERSISTENT/"

# Unlock file permissions
echo "Setting permissions on persistent content..."
"$ADB" shell chmod -R 777 "$PERSISTENT"

echo "Content copied successfully to Quest."
