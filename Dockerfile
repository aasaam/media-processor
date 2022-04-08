FROM alpine

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
