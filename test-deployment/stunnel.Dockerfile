FROM alpine:latest

RUN apk add --no-cache stunnel openssl

# Create necessary directories
RUN mkdir -p /etc/stunnel /certs

# Generate self-signed certificate for test-deployment
RUN openssl req -x509 -nodes -days 3650 \
  -subj "/CN=test-deployment" \
  -newkey rsa:2048 \
  -keyout /certs/privkey.pem \
  -out /certs/fullchain.pem

# Write stunnel configuration for modern TLS only
RUN echo -e "pid = /tmp/stunnel.pid\n\
foreground = yes\n\
debug = 3\n\
setuid = nobody\n\
setgid = nobody\n\
socket = l:TCP_NODELAY=1\n\
socket = r:TCP_NODELAY=1\n\
socket = l:TCP_KEEPIDLE=60\n\
socket = r:TCP_KEEPIDLE=60\n\
socket = l:TCP_KEEPINTVL=10\n\
socket = r:TCP_KEEPINTVL=10\n\
sessionCacheSize = 1000\n\
sessionCacheTimeout = 300\n\
socket = l:SO_KEEPALIVE=1\n\
socket = r:SO_KEEPALIVE=1\n\
\n\
[rtmps]\n\
accept = 0.0.0.0:8443\n\
connect = srv-captain--test-deployment:1935\n\
cert = /certs/fullchain.pem\n\
key = /certs/privkey.pem\n\
client = no\n\
sslVersion = TLSv1.2\n\
options = NO_SSLv2\n\
options = NO_SSLv3\n\
options = NO_TLSv1\n\
options = NO_TLSv1_1\n\
options = NO_COMPRESSION\n\
ciphers = ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256\n\
" > /etc/stunnel/stunnel.conf

CMD ["stunnel", "/etc/stunnel/stunnel.conf"]

EXPOSE 8443