FROM debian:bullseye-slim as builder

ARG DEBIAN_FRONTEND=noninteractive
ARG MOZJPEG_VERSION='v4.0.3'

RUN apt update && \
  apt upgrade -y && \
  apt install build-essential cmake curl wget nasm autoconf libpng-dev -y

RUN cd /tmp && \
  curl -L -o mozjpeg.tgz "https://github.com/mozilla/mozjpeg/archive/refs/tags/${MOZJPEG_VERSION}.tar.gz" && \
  tar xf mozjpeg.tgz && \
  export MOZJPEG_PATH=`realpath /tmp/mozjpeg-*` && \
  mv $MOZJPEG_PATH /tmp/mozjpeg && \
  cd /tmp/mozjpeg && \
  cmake -G"Unix Makefiles" -DENABLE_SHARED=0 -DENABLE_STATIC=1 . && \
  make

FROM alpine

COPY --from=builder /tmp/mozjpeg/cjpeg-static /usr/local/bin/mozjpeg

RUN apk add --no-cache \
  font-noto-arabic \
  font-noto \
  ca-certificates \
  imagemagick \
  ffmpeg \
  file \
  shared-mime-info \
  gifsicle \
  curl
