$CONTENT = "."
$TMP = "/data/local/tmp/Content"
$PERSISTENT = "/storage/emulated/0/Android/data/com.BeAnotherLab.MachineToBeAnother/files/Content"
$ADB = "adb.exe"

Write-Host "Checking ADB connection..."
& $ADB devices

# Clear and recreate temporary content directory
Write-Host "Preparing temporary directory..."
& $ADB shell rm -rf $TMP
& $ADB shell mkdir -p $TMP

# Copy files
Write-Host "Copying files..."
Get-ChildItem -Path $CONTENT -File |
    Where-Object {
        $_.Name -notin @(
            ".DS_Store",
            "copy-content.sh",
            "push-content.ps1"
        )
    } |
    ForEach-Object {
        & $ADB push $_.FullName "$TMP/"
    }

# Copy directories
Get-ChildItem -Path $CONTENT -Directory |
    ForEach-Object {
        & $ADB push $_.FullName "$TMP/"
    }

# Copy to persistent application storage
Write-Host "Copying content to persistent application storage..."

& $ADB shell rm -rf $PERSISTENT
& $ADB shell mkdir -p $PERSISTENT
& $ADB shell cp -r "$TMP/." "$PERSISTENT/"

# Unlock file permissions
Write-Host "Setting permissions on persistent content..."
& $ADB shell chmod -R 777 $PERSISTENT

Write-Host ""
Write-Host "Content copied successfully to Quest." -ForegroundColor Green
