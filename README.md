# vanilla-cherry

Custom [Vib](https://github.com/Vanilla-OS/vib) image.

## Overview

[Vanilla OS](https://github.com/vanilla-os) with my own cherries on top. It is built on `ghcr.io/vanilla-os/gnome:latest` and pulls its default NVIDIA driver module from `vanilla-os/nvidia-exp-image`.

> [!NOTE]
> Personal image. If you do not like my changes, see [Vanilla-OS/custom-image](https://github.com/Vanilla-OS/custom-image) for creating your own.

This is and will always be my personal image. It adds quality-of-life packages over the stock Vanilla OS GNOME image.

## Images

Every image is published for `linux/amd64` and `linux/arm64` as one multi-arch manifest, so `podman pull` and ABRoot pick the right architecture on their own.

| Image | NVIDIA driver |
| --- | --- |
| `ghcr.io/justsaft/vanilla-cherry` | Latest driver, from the `nvidia-exp-image` module |
| `ghcr.io/justsaft/vanilla-cherry-nv580` | Driver 580, pinned, from NVIDIA's own repository |
| `ghcr.io/justsaft/vanilla-cherry-novidia` | None |

The tag is the name of the branch or git tag that was built, so `main` is the current state of the main branch.

## Current additions

- Livestreaming
  - PipeWire virtual sink config, inspired by Elgato Wave Link. Works well with [qpwgraph](https://flathub.org/apps/org.rncbc.qpwgraph) and [Carla](https://flathub.org/apps/studio.kx.carla) or [EasyEffects](https://flathub.org/apps/com.github.wwmm.easyeffects).
  - `pulseaudio-utils`, `alsa-utils`, PipeWire ALSA, V4L2 and JACK bridges, `jackd2` and the LSP plugin suite
  - udev rules for some USB Elgato capture devices, such as the HD60 X
- Gaming: Gamescope, MangoHud, MangoApp, `gamemode` and `libgamemode`
- Hardware
  - OpenRGB 1.0rc3 with the Effects and Visual Map plugins, plus `i2c-tools`
  - LACT 0.10.1 for GPU control (overclock at your own risk!)
  - `usbutils`, `brightnessctl`, `linux-perf`
- Remote and network: `sshfs`, `davfs2`, `krdc`, `krdp`, `kdeconnect`, Syncthing and Tailscale
- GNOME: appindicator, dash-to-dock, gamemode, window-list, autohide top bar, no-annoyance, caffeine and workspace-indicator extensions, plus adw-gtk3 and Adwaita theming for GTK 2, 3, Qt 5 and Qt 6 apps

## Disabled / Not included modules

- Corsair drivers (`ckb-next`)¹
- MC extras: distro libraries for Prism Launcher²

¹Currently non-functional under Vanilla.
²doesn't improve performance.

## How the images are built

All three images come from `recipe.yml`. It is run through the C preprocessor to produce a plain Vib recipe per image.

| Flag | Effect |
| --- | --- |
| `-DIMAGE_NAME=name` | Sets `name` and `id` in the recipe. Defaults to `vanilla-cherry`. |
| `-DBASE_IMAGE=ref` | Sets the base image of the first stage. Defaults to `ghcr.io/vanilla-os/gnome:latest`. |
| `-DNV580` | Uses the pinned 580 driver module. |
| `-DNOVIDIA` | Leaves out the NVIDIA driver. |

Two things to watch when editing `recipe.yml`:

- A slash followed by a star opens a C comment. Quote globs such as `"/tmp/*"`.
- A backslash at the end of a line joins it with the next line.

## Secure Boot

The NVIDIA modules are built by DKMS during the image build, so Secure Boot rejects them unless they are signed with a key that the machine trusts. CI signs them with one key for every user, and each machine enrolls the matching certificate once.

On a machine with Secure Boot enabled, run this once and follow the prompts, which end in the blue MOK manager after a reboot:

```sh
cherry-enroll-mok
```

The enrollment lives in firmware, so image updates and ABRoot rollbacks keep working as long as the signing key stays the same. A new key means everyone enrolls again.

### Setting up the signing key

Generate the key once and keep the private half out of the repository:

```sh
openssl req -new -x509 -newkey rsa:2048 -nodes -days 36500 \
  -keyout mok.key -out mok.pem \
  -subj "/CN=vanilla-cherry module signing/" \
  -addext "basicConstraints=critical,CA:FALSE" \
  -addext "keyUsage=digitalSignature" \
  -addext "extendedKeyUsage=codeSigning"
gh secret set MOK_KEY < mok.key
gh secret set MOK_CERT < mok.pem
```

CI hands both to the build as BuildKit secrets, rebuilds the NVIDIA modules with them and fails the build if any module is not signed by that certificate. The public certificate ends up in the image as `/usr/share/cherryscripts/mok.der`.

- Pushes and tag builds fail without the secrets, so an unsigned image is never published.
- Pull requests without the secrets, such as from forks, build with unsigned modules.
- The `novidia` image has no modules to sign.

## Building locally

```sh
sh scripts/gen-recipe.sh out.recipe-nv580.yml -DIMAGE_NAME=vanilla-cherry-nv580 -DNV580
vib build out.recipe-nv580.yml
podman image build . -t tag
```

The output has to sit in the repo root so that the `modules/` and `out.modules` includes resolve.

## Building on CI

1. Generates the recipe and reads the base image from its first stage.
2. Verifies the base image attestation with `gh attestation verify`.
3. Builds amd64 and arm64 on native runners and pushes each by digest, with no tag.
4. Creates the multi-arch manifest under the real tag with `docker buildx imagetools create`. Pull requests build but push nothing.

## Helper image

LACT and KDE Connect is compiled in [vos-ci-building](https://github.com/justsaft/vos-ci-building) from upstream and consumed here as a release tarball (which keeps build tooling out of this image).
