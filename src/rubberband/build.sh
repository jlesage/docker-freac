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

RUBBERBAND_URL="$1"

if [ -z "$RUBBERBAND_URL" ]; then
    log "ERROR: RubberBand URL missing."
    exit 1
fi

#
# Install required packages.
#
apk --no-cache add \
    curl \
    patch \
    make \
    clang \

xx-apk --no-cache --no-scripts add \
    musl-dev \
    gcc \
    g++ \
    libsndfile-dev \

#
# Download sources.
#

log "Downloading RubberBand package..."
mkdir /tmp/rubberband
curl -# -L -f ${RUBBERBAND_URL} | tar xj --strip 1 -C /tmp/rubberband

#
# Compile RubberBand.
#

log "Patching RubberBand..."
patch -p1 -d /tmp/rubberband < "$SCRIPT_DIR"/rubberband-fixed.patch

log "Configuring RubberBand..."
(
    cd /tmp/rubberband && \
        FFTW_CFLAGS=" " FFTW_LIBS=" " SRC_CFLAGS=" " SRC_LIBS=" " Vamp_CFLAGS=" " Vamp_LIBS=" " \
        SNDFILE_CFLAGS=" " SNDFILE_LIBS="-lsndfile" \
        ./configure \
        --build=$(TARGETPLATFORM= xx-clang --print-target-triple) \
        --host=$(xx-clang --print-target-triple) \
        --prefix=/usr \
)

log "Compiling RubberBand..."
make -C /tmp/rubberband -j$(nproc)

log "Installing RubberBand..."
make DESTDIR=/tmp/rubberband-install -C /tmp/rubberband install
