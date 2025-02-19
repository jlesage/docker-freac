# Docker container for fre:ac
[![Release](https://img.shields.io/github/release/jlesage/docker-freac.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-freac/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/freac/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/freac/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/freac?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/freac)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/freac?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/freac)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-freac/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-freac/actions/workflows/build-image.yml)
[![Source](https://img.shields.io/badge/Source-GitHub-blue?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-freac)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This is a Docker container for [fre:ac](https://www.freac.org).

The GUI of the application is accessed through a modern web browser (no
installation or configuration needed on the client side) or via any VNC client.

---

[![fre:ac logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/freac-icon.png&w=110)](https://www.freac.org)[![fre:ac](https://images.placeholders.dev/?width=192&height=110&fontFamily=monospace&fontWeight=400&fontSize=52&text=fre:ac&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](https://www.freac.org)

fre:ac is a free and open source audio converter. It supports audio CD ripping
and tag editing and converts between various audio file formats.

---

## Quick Start

**NOTE**:
    The Docker command provided in this quick start is given as an example
    and parameters should be adjusted to your need.

Launch the fre:ac docker container with the following command:
```shell
docker run -d \
    --name=freac \
    -p 5800:5800 \
    -v /docker/appdata/freac:/config:rw \
    -v /home/user:/storage:ro \
    -v /home/user/freeac/output:/output:rw \
    --device /dev/sr0 \
    jlesage/freac
```

Where:

  - `/docker/appdata/freac`: This is where the application stores its configuration, states, log and any files needing persistency.
  - `/home/user`: This location contains files from your host that need to be accessible to the application.
  - `/home/user/freeac/output`: This is where encoded audio files are stored.
  - `/dev/sr0`: This is the Linux device file representing the optical drive.

Browse to `http://your-host-ip:5800` to access the fre:ac GUI.
Files from the host appear under the `/storage` folder in the container.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-freac.

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

For other great Dockerized applications, see https://jlesage.github.io/docker-apps.

[create a new issue]: https://github.com/jlesage/docker-freac/issues
