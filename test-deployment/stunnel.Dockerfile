FROM alpine:latest

RUN apk add --no-cache stunnel

RUN mkdir -p /etc/stunnel && \
  echo -e "pid = /var/run/stunnel.pid\n\
foreground = yes\n\
debug = 7\n\
\n\
[rtmps]\n\
accept = 8443\n\
connect = srv-captain--test-deployment:1935\n\
cert = /certs/fullchain2.pem\n\
key = /certs/privkey2.pem\n\
client = no\n\
sslVersion = TLSv1\n\
options = NO_SSLv2\n\
options = NO_SSLv3\n\
options = NO_COMPRESSION\n\
ciphers = RSA+AES:!ECDHE:!ECDSA:!AESGCM:!CHACHA20:!HIGH:!aNULL:!eNULL:!EXP:!MD5" > /etc/stunnel/stunnel.conf

CMD ["stunnel", "/etc/stunnel/stunnel.conf"]

EXPOSE 8443