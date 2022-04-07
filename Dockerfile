FROM debian:bullseye-slim as builder

ARG DEBIAN_FRONTEND=noninteractive
ARG MOZJPEG_VERSION='v4.0.3'

RUN apt update && \
  apt upgrade -y && \
  apt install build-essential cmake curl wget nasm libpng-dev -y

RUN cd /tmp && \
  curl -L -o mozjpeg.tgz "https://github.com/mozilla/mozjpeg/archive/refs/tags/${MOZJPEG_VERSION}.tar.gz" && \
  tar xf mozjpeg.tgz && \
  cd mozjpeg-* && \
  cmake -G"Unix Makefiles" -DENABLE_SHARED=0 -DENABLE_STATIC=1 . && \
  make && make install

FROM debian:bullseye-slim

ARG GIFSICLE_VERSION='v1.93'

COPY --from=builder /opt/mozjpeg/bin /opt/mozjpeg/bin
COPY --from=builder /opt/mozjpeg/lib64 /opt/mozjpeg/lib64

RUN apt update && \
  apt upgrade -y && \
  apt install build-essential autoconf cmake wget curl \
  ffmpeg libfile-mimeinfo-perl libimage-exiftool-perl dcmtk shared-mime-info libfribidi-bin fonts-noto-core pngquant -y && \
  cd /tmp && \
  wget -O gifsicle.tgz "https://github.com/kohler/gifsicle/archive/refs/tags/${GIFSICLE_VERSION}.tar.gz" && \
  tar xf gifsicle.tgz && \
  cd gifsicle-* && \
  autoreconf -i && ./configure && make && make install && \
  t=$(mktemp) && \
  wget 'https://dist.1-2.dev/imei.sh' -qO "$t" && \
  bash "$t" && \
  rm "$t" && \
  apt purge build-essential autoconf cmake wget -y && \
  apt auto-remove -y && \
  apt clean && \
  rm -r /var/lib/apt/lists/* && rm -rf /tmp && mkdir /tmp && chmod 777 /tmp && truncate -s 0 /var/log/*.log
