# The Machine to Be Another (Mobile)

This repository contains the mobile version of The Machine to Be Another, adapted for standalone VR headsets. It is a minimal, self-contained port of the original desktop experience: two headsets connected over a local network, each sharing the other’s view through swapped camera input and guided interaction. The UVC pipeline is based on [UVC4UnityAndroid](https://github.com/saki4510t/UVC4UnityAndroid) by saki4510

## Overview

[The Machine to Be Another](https://beanotherlab.org/home/work/tmtba/body-swap/) is an embodiment experience in which two participants inhabit each other's perspective through live camera feed, synchronized interaction, and human-guided steps. It has been shown as an interactive installation worldwide. This mobile port is designed for standalone VR headsets and supports the same core interaction model in a more compact, self-contained form.

## System Diagarm

![Setup diagram](Docs/setup%20diagram.png)

## Requirements

- Two Meta Quest 2 or Meta Quest 3
- Horizon OS v2.7+
- Unity 6000.0f1
- Android Debug Bridge (ADB)
- Two USBFHD01M usb cameras with corresponding USB adapters and extension cables
- TouchOSC Legacy on an Android or iOS tablet/phone device

## Installation and setup

### 1. Installing the app

Open the project in Unity and build the app for Android / Meta Quest. If you select "build and run", the content files will be automatically copied with the build. 

Otherwise, you can use the .apk and the `copy-content` script included in the release to update the packaged experience content onto the headset.

From the Content folder root:

```bash
./copy-content.sh
```
on Linux/Mac OS or

```bash
./copy-content.ps1
```
on Windows

The script copies the `Content` directory into the Quest app storage and sets file permissions. If your `adb` binary is not found update the script path before running it.

### 2. Prepare the camera setup

The project uses USB camera input connected directly to the headset. The repository includes mounting files and documentation for the hardware setup. Example 3D printable mount files are available in [`Files/Mounts`](Files/mounts)

### 3. Config and Debug UI
Before launching the app, make sure the headsets are connected to your local wifi network, as well as the tablet.
On the first usage, press the right index trigger and the A button to bring the Debug UI up. Before you can connect to another headset, make sure the "host" checkbox is enabled on one of the headsets only. You can enable the `Pano` object at the top of the hierarchy to check the video feed is showing properly. Then set the exposure level with the slider to adjust the image to the light conditions.

## Tablet controller setup

The experience includes TouchOSC layouts for use as a controller or operator interface. in the TouchOSC interface you must set the IP address of the Host headset to be able to send control messages to both devices.

Install TouchOSC Legacy on the Android device and load one of the controller layouts from the repository:

- [`Files/bodyswap controller.touchosc`](Files/bodyswap%20controller.touchosc) — regular manual swap controls
- [`Files/bodyswap controller bonus.touchosc`](Files/bodyswap%20controller%20bonus.touchosc) — manual swap controls with an extra slot for an audio instruction
- [`Files/body swap controller curtain.touchosc`](Files/body%20swap%20controller%20curtain.touchosc) — manual swap controls with controls for an automated curtain

These layouts are intended to support the manual swap interaction flow and operator controls during the experience.

## JSON-driven Experience customization  

You can customize several aspects of the experience (visuals, localization texts and audio) using the project’s JSON-driven configuration and sequencing logic.
It is documented in the following references:

- [JSON Sequencer README](Docs/JSON-Sequencer-README.md) — sequence flow, timing, actions, localization, and authoring guidance.
- [JSON Config and Static Asset Loading README](Docs/JSON-Config-and-Static-Asset-Loading-README.md) — configuration schema and runtime asset-loading behavior.
