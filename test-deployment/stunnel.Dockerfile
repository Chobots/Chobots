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
RUN echo -e "pid = /var/run/stunnel.pid\n\
foreground = yes\n\
debug = 7\n\
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
ciphers = ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305" > /etc/stunnel/stunnel.conf

CMD ["stunnel", "/etc/stunnel/stunnel.conf"]

EXPOSE 8443