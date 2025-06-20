#
# freac Dockerfile
#
# https://github.com/jlesage/docker-freac
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG FREAC_VERSION=1.1.7-r0

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.21-v4.8.0

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
#COPY --from=freac /tmp/freeac-install/ /

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
