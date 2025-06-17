# vanilla-cherry
Custom Vib image.

## Overview

[Vanilla-OS](https://github.com/vanilla-os) but lightly customized with my own cherries on top. Based off of `vanilla-os/nvidia-exp`

> [!NOTE]
> Personal image. If you do not like my changes, please refer to [https://github.com/Vanilla-OS/custom-image](https://github.com/Vanilla-OS/custom-image) for creating custom images.

## Goal
This is and will always be my personal image, containing QoL additions over the base Vanilla OS desktop image.


### Current additions:
- QoL additions for livestreaming
  - PipeWire virtual sink config (Elgato Wave Link-inspired), useful when used with [qpwgraph](https://flathub.org/apps/org.rncbc.qpwgraph) and [Carla](https://flathub.org/apps/studio.kx.carla)/[EasyEffects](https://flathub.org/apps/com.github.wwmm.easyeffects)
  - pulseaudio-utils
  - udev rules for some USB based Elgato game capture devices (e.g. HD60 X)
- Addition: `usbutils`
- Addition: `evremap` for remapping keys
- Addition: OpenRGB udev rules¹
- Addition: Gamescope, MangoHud, MangoApp
- Addition: libgamemode
- Addition: `libglfw3` and `libopenal1` for PrismLauncher³


### Current non-included additions:
- Addition: Corsair drivers (`ckb-next`)²


¹ Note: You'll still need the [OpenRGB flatpak](https://flathub.org/apps/org.openrgb.OpenRGB)
² Note: Currently non-working under Vanilla.
³ Note: Technically not nessesary, the launcher bundles these itself. --> They are here for testing if performance increases.
