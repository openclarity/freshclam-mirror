# syntax=docker/dockerfile:1@sha256:ac85f380a63b13dfcefa89046420e1781752bab202122f8f50032edf31be0021

FROM alpine:3.20@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5

RUN apk add --no-cache ca-certificates nginx

ADD --link nginx/default.conf /etc/nginx/http.d/default.conf

RUN nginx -t

RUN apk add --no-cache freshclam=1.2.2-r0

ADD --link --chmod=644 clamav/freshclam.conf /etc/clamav/freshclam.conf

VOLUME ["/var/lib/clamav"]

# Fail the build if downloading updates gets rate-limited
RUN <<EOT
  set -eo pipefail

  if freshclam --stdout --verbose | grep -i -e 'on cool-down until after' -e 'received error code 429 or 403'
  then
    printf "ERROR: %s\n" "failed to update one or more databases due to rate-limiting..."
    exit 1
  fi

EOT

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
  rm -f "${archive}"
EOT

ADD --link --chmod=755 s6-rc.d/freshclam /etc/s6-overlay/s6-rc.d/freshclam
ADD --link --chmod=755 s6-rc.d/nginx /etc/s6-overlay/s6-rc.d/nginx
ADD --link --chmod=755 s6-rc.d/user/contents.d/* /etc/s6-overlay/s6-rc.d/user/contents.d/

ENTRYPOINT ["/init"]
