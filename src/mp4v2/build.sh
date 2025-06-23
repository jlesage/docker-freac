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
    log "ERROR: MP4v2 URL missing."
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

log "Downloading MP4v2 package..."
mkdir /tmp/mp4v2
curl -# -L -f ${MP4V2_URL} | tar xj --strip 1 -C /tmp/mp4v2

#
# Compile MP4v2.
#

log "Configuring MP4v2..."
(
    mkdir /tmp/mp4v2/build && \
    cd /tmp/mp4v2/build && cmake \
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

log "Compiling MP4v2..."
make prefix=/usr -C /tmp/mp4v2/build -j$(nproc)

log "Installing MP4v2..."
make DESTDIR=/tmp/mp4v2-install -C /tmp/mp4v2/build install
