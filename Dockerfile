FROM --platform=$BUILDPLATFORM alpine:latest AS builder
RUN apk add --no-cache curl bzip2 tar unzip

ARG RCLONE_VERSION
ARG RESTIC_VERSION
ARG RESTICPROFILE_VERSION
ARG TARGETPLATFORM

WORKDIR /tmp

RUN echo "### Rclone Version: $RCLONE_VERSION"
RUN echo "### Restic Version: $RESTIC_VERSION"
RUN echo "### Resticprofile Version: $RESTICPROFILE_VERSION"

RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d'/' -f2) && \
    if [ "$ARCH" = "arm64" ]; then rclone_arch="arm64"; else rclone_arch="amd64"; fi && \
    
    # Rclone
    url="https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${rclone_arch}.zip" && \
    echo "### Rclone URL: $url" && \
    curl -f -L -o rclone.zip $url && \
    unzip rclone.zip && \
    mv rclone-v${RCLONE_VERSION}-linux-${rclone_arch}/rclone /usr/bin/rclone && \
    chmod +x /usr/bin/rclone && \

    # Restic
    url="https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_${ARCH}.bz2" && \
    echo "### Restic URL: $url" && \
    curl -f -L -o restic.bz2 $url && \
    bunzip2 restic.bz2 && \
    mv restic /usr/bin/restic && \
    chmod +x /usr/bin/restic && \
        
    # Resticprofile
    url="https://github.com/creativeprojects/resticprofile/releases/download/v${RESTICPROFILE_VERSION}/resticprofile_${RESTICPROFILE_VERSION}_linux_${ARCH}.tar.gz" && \
    echo "### Resticprofile URL: $url" && \
    curl -f -L -o resticprofile.tar.gz $url && \
    tar -xzf resticprofile.tar.gz && \
    mv resticprofile /usr/bin/resticprofile && \
    chmod +x /usr/bin/resticprofile

FROM alpine:latest
RUN apk add --no-cache ca-certificates fuse openssh-client tzdata bash
COPY --from=builder /usr/bin/rclone /usr/bin/restic /usr/bin/resticprofile /usr/bin/
