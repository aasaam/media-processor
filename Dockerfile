FROM alpine as builder

ARG MOZJPEG_VERSION='v4.0.3'

RUN apk add --no-cache \
  autoconf automake libtool make tiff jpeg zlib zlib-dev pkgconf nasm file gcc musl-dev curl cmake ca-certificates

RUN cd /tmp && \
  curl -L -o mozjpeg.tgz "https://github.com/mozilla/mozjpeg/archive/refs/tags/${MOZJPEG_VERSION}.tar.gz" && \
  tar xf mozjpeg.tgz && \
  export MOZJPEG_PATH=`realpath /tmp/mozjpeg-*` && \
  mv $MOZJPEG_PATH /tmp/mozjpeg && \
  cd /tmp/mozjpeg && \
  cmake -G"Unix Makefiles" -DENABLE_SHARED=0 -DENABLE_STATIC=1 -DPNG_SUPPORTED=NO . && \
  make

FROM alpine

COPY --from=builder /tmp/mozjpeg/cjpeg-static /usr/local/bin/mozjpeg

RUN apk add --no-cache \
  font-noto-arabic \
  font-noto \
  exiftool \
  ca-certificates \
  imagemagick \
  ffmpeg \
  file \
  shared-mime-info \
  perl-archive-zip \
  gifsicle \
  pngquant \
  curl
