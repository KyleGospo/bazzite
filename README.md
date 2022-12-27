# Bazzite

[![build-bazzite](https://github.com/kylegospo/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/kylegospo/bazzite/actions/workflows/build.yml)

Bazzite is an OCI based off of [Fedora Kinoite](https://kinoite.fedoraproject.org/) that is intended to be an alternative OS for the [Steam Deck](https://www.steamdeck.com/).

### Bazzite is currently in development and should not be used on real hardware under any circumstance. Feel free to test in a VM.
### Bazzite is not associated with Valve Software in any way, and maintainers of the Bazzite project are not liable for any damage that may occur during use of the operating system.

## Usage

Warning: This is an experimental feature and should not be used in production, try it in a VM for a while, you have been warned!

    sudo rpm-ostree rebase --experimental ostree-unverified-registry:ghcr.io/kylegospo/bazzite:latest
    
We build date tags as well, so if you want to rebase to a particular day's release:
  
    sudo rpm-ostree rebase --experimental ostree-unverified-registry:ghcr.io/kylegospo/bazzite:20221217 

The `latest` tag will automatically point to the latest build. 

## Features

- Start with a base Fedora Kinoite 37 image
- Adds ported versions of Valve's Steam Deck packages
- Adds h264 decoding out of the box via RPM Fusion
- Supports LatencyFleX & vkBasalt out of the box
- Ships with Distrobox already installed
- Comes with services for automatic system, distrobox, and flatpak updates.
- Built in duperemove
- BTRFS by default, including the SD card
- Matches SteamOS 1:1 whenever possible
  
## Copr

Ported SteamOS and ChimeraOS packages used by Bazzite are built on Copr in [this repo](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/).

|Package|Status|
|---|---|
|gamescope-session|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session/status_image/last_build.png?)|
|jupiter-fan-control|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-fan-control/status_image/last_build.png?)|
|jupiter-hw-support|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support/status_image/last_build.png?)|
|steamdeck-kde-presets|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)|

## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/kylegospo/bazzite