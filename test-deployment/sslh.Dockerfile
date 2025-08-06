ARG ALPINE_VERSION="latest"
ARG TARGET_ARCH="library"

FROM alpine:latest AS build

RUN apk add --no-cache \
        gcc \
        libconfig-dev \
        make \
        musl-dev \
        pcre2-dev \
        perl \
        git

RUN git clone https://github.com/yrutschle/sslh.git \
 && cd sslh \
 && ./configure \
 && make sslh-fork

FROM alpine:latest

COPY --from=build "/sslh/sslh-fork" "/usr/local/bin/sslh-fork"

RUN apk add --no-cache \
        libconfig \
        pcre2 \
        iptables \
        ip6tables \
        libcap \
        libcap-utils \
    && adduser -s '/bin/sh' -S -D sslh \
    && setcap cap_net_bind_service,cap_net_raw+ep /usr/local/bin/sslh-fork

RUN mkdir -p /etc \
 && printf '%s\n' \
    'verbose: 2;' \
    'timeout: 5;' \
    'foreground: true;' \
    '' \
    'listen:' \
    '(' \
    '  { host: "0.0.0.0"; port: "8443"; }' \
    ');' \
    '' \
    'protocols:' \
    '(' \
    '  {' \
    '    name: "tls";' \
    '    host: "captain-nginx";' \
    '    port: "443";' \
    '  }' \
    ');' > /etc/sslh.cfg

EXPOSE 8443
ENTRYPOINT [""]
CMD ["sslh-fork", "-v", "99", "-f", "-F", "/etc/sslh.cfg"]