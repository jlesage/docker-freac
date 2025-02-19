#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure the configuration directory exists.
mkdir -p "$XDG_CONFIG_HOME"/.freac

# Install default configuration.
[ -f "$XDG_CONFIG_HOME"/.freac/freac.xml ] || cp -v /defaults/freac.xml "$XDG_CONFIG_HOME"/.freac/freac.xml

# Take ownership of the output directory.
take-ownership --not-recursive /output

# vim:ft=sh:ts=4:sw=4:et:sts=4
