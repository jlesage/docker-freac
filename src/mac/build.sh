#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Set same default compilation flags as abuild.
export CFLAGS="-Os -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,--strip-all -Wl,--as-needed"

export CC=xx-clang
export CXX=xx-clang++

function log {
    echo ">>> $*"
}

MP4V2_URL="$1"

if [ -z "$MP4V2_URL" ]; then
    log "ERROR: Monkey's Audio Compressor URL missing."
    exit 1
fi

#
# Install required packages.
#
apk --no-cache add \
    curl \
    make \
    cmake \
    clang \

xx-apk --no-cache --no-scripts add \
    musl-dev \
    gcc \
    g++ \

#
# Download sources.
#

log "Downloading Monkey's Audio Compressor package..."
mkdir /tmp/mac
curl -# -L -f -o /tmp/mac.zip ${MP4V2_URL}
unzip -d /tmp/mac /tmp/mac.zip

#
# Compile Monkey's Audio Compressor.
#

log "Configuring Monkey's Audio Compressor..."
(
    mkdir /tmp/mac/build && \
    cd /tmp/mac/build && cmake \
        $(xx-clang --print-cmake-defines) \
        -DCMAKE_FIND_ROOT_PATH=$(xx-info sysroot) \
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        ..
)

log "Compiling Monkey's Audio Compressor..."
make prefix=/usr -C /tmp/mac/build -j$(nproc)

log "Installing Monkey's Audio Compressor..."
make DESTDIR=/tmp/mac-install -C /tmp/mac/build install
