FROM nginx:1.25.3-alpine-slim

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community freshclam

ADD --link --chmod=644 clamav/freshclam.conf /etc/clamav/freshclam.conf

# Fail the build if downloading updates gets rate-limited
RUN freshclam --stdout --verbose --on-update-execute=/bin/false

ADD --link nginx/default.conf /etc/nginx/conf.d/default.conf

RUN nginx -t

ARG TARGETPLATFORM

RUN <<EOT
  set -e

  version=3.1.6.2
  url=
  checksum=

  ## Install s6-overlay scripts
  url=https://github.com/just-containers/s6-overlay/releases/download/v${version}/s6-overlay-noarch.tar.xz
  checksum=05af2536ec4fb23f087a43ce305f8962512890d7c71572ed88852ab91d1434e3

  archive="$(basename ${url})"
  wget -q -O "${archive}" "${url}"
  printf "%s %s" "${checksum}" "${archive}" | sha256sum -c -
  tar -C / -Jxpf "${archive}"

  ## Install s6-overlay binaries
  case "$TARGETPLATFORM" in
    "linux/amd64")
      url=https://github.com/just-containers/s6-overlay/releases/download/v${version}/s6-overlay-x86_64.tar.xz
      checksum=95081f11c56e5a351e9ccab4e70c2b1c3d7d056d82b72502b942762112c03d1c
      ;;
    "linux/arm64")
      url=https://github.com/just-containers/s6-overlay/releases/download/v${version}/s6-overlay-aarch64.tar.xz
      checksum=3fc0bae418a0e3811b3deeadfca9cc2f0869fb2f4787ab8a53f6944067d140ee
      ;;
    *)
      printf "ERROR: %s" "invalid architecture"
      exit 1
  esac

  archive="$(basename ${url})"
  wget -q -O "${archive}" "${url}"
  printf "%s %s" "${checksum}" "${archive}" | sha256sum -c -
  tar -C / -Jxpf "${archive}"
EOT

ADD --link --chmod=755 s6-rc.d/freshclam /etc/s6-overlay/s6-rc.d/freshclam
ADD --link --chmod=755 s6-rc.d/nginx /etc/s6-overlay/s6-rc.d/nginx
ADD --link --chmod=755 s6-rc.d/user/contents.d/* /etc/s6-overlay/s6-rc.d/user/contents.d/

ENTRYPOINT ["/init"]
