#!/bin/bash

CONTENT="./Content"
TMP="/data/local/tmp/Content"
PERSISTENT="/storage/emulated/0/Android/data/com.BeAnotherLab.MachineToBeAnother/files/Content"
ADB="/opt/homebrew/bin/adb"

# Check ADB
$ADB devices

# Clear and recreate temporary content directory
$ADB shell rm -rf "$TMP"
$ADB shell mkdir -p "$TMP"

# Copy files
find "$CONTENT" -maxdepth 1 -type f ! -name ".DS_Store" -exec "$ADB" push "{}" "$TMP/" \;

# Copy directories
find "$CONTENT" -mindepth 1 -maxdepth 1 -type d -exec "$ADB" push "{}" "$TMP/" \;

# Copy to persistent application storage
$ADB shell rm -rf "$PERSISTENT"
$ADB shell mkdir -p "$PERSISTENT"
$ADB shell cp -r "$TMP/." "$PERSISTENT/"

echo "Content copied successfully to Quest."
