# The Machine to Be Another (Mobile)

This repository contains the mobile version of The Machine to Be Another, adapted for standalone VR headsets. It is a minimal, self-contained port of the original desktop experience: two headsets connect directly over the local network, exchange camera and interaction data, and run the experience without a PCVR setup.

This is the first prototype build of The Machine to Be Another (Manual Swap) for standalone headsets.

## Overview

The Machine to Be Another is a remote embodiment experience in which two participants inhabit each other's perspective through live camera feed, synchronized interaction, and guided steps. This mobile build is designed for Meta Quest devices and keeps the experience self-contained on each headset.

- Tested on Meta Quest 3 and Meta Quest 2 running Horizon OS v2.7
- Built with Unity 6000.0f1
- Intended for QA, UX, and exhibition validation
- Not a final production deployment
- Designed for local network communication between two headsets
- Camera pipeline based on UVC4UnityAndroid by saki
- Expected camera latency remains under 100 ms

![Setup diagram](Docs/setup%20diagram.png)

## Project status

This project is a prototype and is intentionally limited in scope. It is intended to validate the interaction model, camera pipeline, and local network setup on standalone VR hardware.

- Works on standalone Meta Quest devices
- No longer works on desktop devices without modification
- Built for experimentation and exhibition use rather than final deployment

## Repository structure

```text
.
├── Assets/                  # Unity project assets and scenes
├── Content/                 # Experience content packaged for the headset
│   ├── Audio/
│   ├── Config/
│   ├── Font/
│   ├── Image/
│   ├── Template/
│   ├── Translation/
│   ├── Video/
│   └── ...
├── Docs/                    # Setup and technical documentation
├── Files/                   # Mounts, controller layouts, manuals, and PDFs
├── Packages/                # Unity package manifest
├── ProjectSettings/         # Unity project settings
├── copy-content.sh          # Copies content to the Quest via ADB
├── README.md
└── ...
```

## Requirements

- Meta Quest 2 or Meta Quest 3
- Horizon OS v2.7+
- Unity 6000.0f1
- Android Debug Bridge (ADB)
- USB camera hardware compatible with Android UVC input
- TouchOSC Legacy on an Android tablet/controller device

## Installation and setup

### 1. Build and install the app

Open the project in Unity and build the app for Android / Meta Quest. After installation, use the included script to push the packaged experience content onto the headset.

From the repository root:

```bash
./copy-content.sh
```

The script copies the `Content` directory into the Quest app storage and sets file permissions.

```bash
#!/bin/bash
CONTENT="./Content"
TMP="/data/local/tmp/Content"
PERSISTENT="/storage/emulated/0/Android/data/com.BeAnotherLab.MachineToBeAnother/files/Content"
ADB="/opt/homebrew/bin/adb"

# Copy files and folders to device
find "$CONTENT" -maxdepth 1 -type f ! -name ".DS_Store" -exec "$ADB" push "{}" "$TMP/" \;
find "$CONTENT" -mindepth 1 -maxdepth 1 -type d -exec "$ADB" push "{}" "$TMP/" \;

$ADB shell rm -rf "$PERSISTENT"
$ADB shell mkdir -p "$PERSISTENT"
$ADB shell cp -r "$TMP/." "$PERSISTENT/"
$ADB shell chmod -R 777 "$PERSISTENT"
```

If your `adb` binary is not installed at `/opt/homebrew/bin/adb`, update the script path before running it.

### 2. Prepare the camera setup

The project uses USB camera input via UVC drivers on Android. The repository includes mounting files and documentation for the hardware setup.

Relevant assets:

- `Files/mounts.zip`
- `Files/mounts.blend`
- `Files/mount DK2.stl`
- `Docs/Meta Horizon OS - USB Camera Compatibility.odt`

For the physical mount, use the 3D printed mounts provided in the repo. The `.blend` and `.zip` files contain the relevant designs for fabrication or adaptation.

## Tablet controller setup

The experience includes TouchOSC layouts for use as a controller or operator interface.

Install TouchOSC Legacy on the Android device and load one of the controller layouts from the repository:

- `Files/bodyswap controller.touchosc`
- `Files/bodyswap controller bonus.touchosc`
- `Files/body swap controller curtain.touchosc`

These layouts are intended to support the manual swap interaction flow and operator controls during the experience.

## JSON configuration system

The experience content is configured with JSON files under `Content/Config`.

### Example configuration

```json
{"selected_languages": ["EN", "FR"]}
```

This file sets active language entries for the experience.

### Sequence configuration

The sequence is defined in `Content/Config/sequence.json` and drives the guided flow of events, including scripting of text, audio, video, and actions.

Example structure:

```json
{
  "steps": [
    {
      "time": 0.0,
      "textKey": "welcome",
      "audio": "welcome.ogg",
      "actions": ["WallOn"]
    }
  ]
}
```

The timeline format supports:

- `time`: when the step occurs
- `textKey`: a localized text entry
- `audio`: an audio file to play
- `visual`: a visual asset to display
- `actions`: scripted actions such as panel visibility or environment changes

For the full specification, see:

- `Docs/JSON-Based Timeline Specification - v2.pdf`

## Content package

The `Content` directory contains the experience assets delivered to the headset, including:

- `Content/Audio/` for narration and sound cues
- `Content/Config/` for localization and sequence configuration
- `Content/Image/` and `Content/Video/` for visual instructions and media
- `Content/Translation/` for localizable strings
- `Content/Template/` for reusable structure and content templates

## Documentation and reference material

The repository includes several technical and operational documents:

- `Docs/setup diagram.png` — system overview diagram
- `Docs/Meta Horizon OS - USB Camera Compatibility.odt` — compatibility notes for Quest/UVC camera use
- `Docs/Meta Quest 3 UVC Camera : Overlay Keyboard issue.pdf` — known issue documentation
- `Docs/JSON-Based Timeline Specification - v2.pdf` — detailed JSON timeline format
- `Docs/Technorama/` — concept and system flow materials
- `Files/The Machine to Be Another Protocols.pdf` — protocol and usage reference
- `Files/swap manual instructions/` — operational instructions

## Notes

This prototype is best understood as a hardware + interaction validation platform for a local, connected VR embodiment experience. It is intentionally lightweight and designed around direct headset-to-headset communication, live camera input, and configurable media-driven interaction sequences.

For questions or implementation details, refer to the files in `Docs/` and `Files/`, or inspect the project configuration under `Content/Config`.
