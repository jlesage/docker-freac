#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure the configuration directory exists.
mkdir -p "$XDG_CONFIG_HOME"/.freac
mkdir -p "$XDG_CONFIG_HOME"/gtk-3.0

# Install default configuration.
[ -f "$XDG_CONFIG_HOME"/.freac/freac.xml ] || cp -v /defaults/freac.xml "$XDG_CONFIG_HOME"/.freac/freac.xml
[ -f "$XDG_CONFIG_HOME"/gtk-3.0/bookmarks ] || cp -v /defaults/bookmarks "$XDG_CONFIG_HOME"/gtk-3.0/bookmarks

# Take ownership of the output directory.
take-ownership --not-recursive --skip-if-writable /output

# vim:ft=sh:ts=4:sw=4:et:sts=4
