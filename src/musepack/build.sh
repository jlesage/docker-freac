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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() {
    echo ">>> $*"
}

MUSEPACK_URL="$1"

if [ -z "$MUSEPACK_URL" ]; then
    log "ERROR: Musepack URL missing."
    exit 1
fi

#
# Install required packages.
#
apk --no-cache add \
    curl \
    patch \
    make \
    cmake \
    clang \
    autoconf \
    automake \
    intltool \
    pkgconfig \
    libtool \

xx-apk --no-cache --no-scripts add \
    musl-dev \
    gcc \
    g++ \

#
# Download sources.
#

log "Downloading Musepack package..."
mkdir /tmp/musepack
curl -# -L -f ${MUSEPACK_URL} | tar xz --strip 1 -C /tmp/musepack

#
# Compile Musepack.
#

log "Patching Musepack..."
patch -p1 -d /tmp/musepack < "$SCRIPT_DIR"/configure-fix.patch
patch -p1 -d /tmp/musepack < "$SCRIPT_DIR"/includes-fix.patch
patch -p1 -d /tmp/musepack < "$SCRIPT_DIR"/extern-const-fix.patch

log "Configuring Musepack..."
(
    cd /tmp/musepack && autoreconf -ivf && ./configure \
        --build=$(TARGETPLATFORM= xx-clang --print-target-triple) \
        --host=$(xx-clang --print-target-triple) \
        --prefix=/usr \
        --disable-shared \
)

log "Compiling Musepack..."
make -C /tmp/musepack -j$(nproc)

log "Installing Musepack..."
make DESTDIR=/tmp/musepack-install -C /tmp/musepack install
