#
# freac Dockerfile
#
# https://github.com/jlesage/docker-freac
#
# See `freac-1.1.7/tools/build-codecs` for codecs version used by fre:ac. Also
# see the following page for the AppImage build details:
#  https://github.com/enzo1982/freac/blob/master/.github/workflows/tools/build-appimage
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG FREAC_VERSION=1.1.7-r0
ARG MP4V2_VERSION=2.1.3
ARG MUSEPACK_VERSION=475
ARG MAC_VERSION=920
ARG RUNNERBAND_VERSION=1.8.2

# Define software download URLs.
ARG MP4V2_URL=https://github.com/enzo1982/mp4v2/releases/download/v${MP4V2_VERSION}/mp4v2-${MP4V2_VERSION}.tar.bz2
ARG MUSEPACK_URL=https://files.musepack.net/source/musepack_src_r${MUSEPACK_VERSION}.tar.gz
ARG MAC_URL=https://freac.org/patches/MAC_${MAC_VERSION}_SDK.zip
ARG RUBBERBAND_URL=https://breakfastquay.com/files/releases/rubberband-${RUNNERBAND_VERSION}.tar.bz2

# Get Dockerfile cross-compilation helpers.
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

# Build MP4v2.
FROM --platform=$BUILDPLATFORM alpine:3.21 AS mp4v2
ARG TARGETPLATFORM
ARG MP4V2_URL
COPY --from=xx / /
COPY src/mp4v2 /build
RUN /build/build.sh "$MP4V2_URL"
RUN xx-verify /tmp/mp4v2-install/usr/lib/libmp4v2.so

# Build Musepack.
FROM --platform=$BUILDPLATFORM alpine:3.21 AS musepack
ARG TARGETPLATFORM
ARG MUSEPACK_URL
COPY --from=xx / /
COPY src/musepack /build
RUN /build/build.sh "$MUSEPACK_URL"
RUN xx-verify \
    /tmp/musepack-install/usr/bin/mpcdec \
    /tmp/musepack-install/usr/bin/mpcenc

# Build Monkey's Audio Compressor.
FROM --platform=$BUILDPLATFORM alpine:3.21 AS mac
ARG TARGETPLATFORM
ARG MAC_URL
COPY --from=xx / /
COPY src/mac /build
RUN /build/build.sh "$MAC_URL"
RUN xx-verify /tmp/mac-install/usr/lib/libMAC.so

# Build RubberBand.
FROM --platform=$BUILDPLATFORM alpine:3.21 AS rubberband
ARG TARGETPLATFORM
ARG RUBBERBAND_URL
COPY --from=xx / /
COPY src/rubberband /build
RUN /build/build.sh "$RUBBERBAND_URL"
RUN xx-verify /tmp/rubberband-install/usr/lib/librubberband.so

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.21-v4.8.1

ARG FREAC_VERSION
ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Install fre:ac.
RUN \
     add-pkg freac=${FREAC_VERSION}

# Install extra packages.
RUN \
    add-pkg \
        adwaita-icon-theme \
        # lsb_release called by fre:ac.
        lsb-release-minimal \
        # Audio encoders, decoders and tools.
        faad2-libs \
        fdk-aac \
        lame-libs \
        libflac \
        libogg \
        libsamplerate \
        libsndfile \
        libvorbis \
        opus \
        rnnoise \
        speex \
        ffmpeg \
        ttaenc \
        wavpack \
        # For optical drive detection.
        lsscsi \
        # Need a font.
        ttf-dejavu

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/freac-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=mp4v2 /tmp/mp4v2-install/usr/lib /usr/lib
COPY --from=musepack /tmp/musepack-install/usr/bin/mpcdec /usr/bin/
COPY --from=musepack /tmp/musepack-install/usr/bin/mpcenc /usr/bin/
COPY --from=mac /tmp/mac-install/usr/lib /usr/lib
COPY --from=rubberband /tmp/rubberband-install/usr/lib /usr/lib

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "fre:ac" && \
    set-cont-env APP_VERSION "$FREAC_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Define mountable directories.
VOLUME ["/storage"]
VOLUME ["/output"]

# Metadata.
LABEL \
      org.label-schema.name="freac" \
      org.label-schema.description="Docker container for fre:ac" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-freac" \
      org.label-schema.schema-version="1.0"
