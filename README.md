# The-Machine-to-be-Another-Mobile 

This is the repository for The Machine to be Another mobile version. This is a port to standalone devices of the existing Machine to be Another Unity desktop version

This is the first prototype build of **The Machine to be Another (Manual Swap)** for standalone headsets

It is meant as a minimalist version of our Machine-to-be-Another system, that doesn't rely on PCVR any longer. The two headsets automatically connect to each other and communicate over local network. To run a swap, simply swap the camera connection directly to the headsets. You'll need an Android tablet or an iPad to control the system.
 
Here's a diagram of the system

- Tested on **Meta Quest 3** and **Meta Quest 2**, running **Horizon OS v2.7**.  
- Built using **Unity 6000.060f1**
- No longer works on desktop devices without modification.  
- Intended for **QA, UX, and exhibition validation** — not final production deployment.  
- Camera latency is expected to stay under **100ms**.  
  
The camera pipeline is based on UVC4UnityAndroid by saki

## Installation  
  
After installing the app, use the `copy-content.sh` script to push experience content to the headset:  
  
./copy-content.sh

## Mounting the cameras

To mount the cameras on the headset, you'll need 3D printed mounts from here.

## Setting up the tablet controller

Install TouchOSC legacy on your Android device and load the touch osc layout forom here bodyswap controller bonus.touchosc

## Customizing the experience (using the .json configuration system )

For the full reference of the json functionality, checkout the docs- 