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
sslVersionMin = TLSv1.2\n\
sslVersionMax = TLSv1.3\n\
ciphers = ALL" > /etc/stunnel/stunnel.conf

CMD ["stunnel", "/etc/stunnel/stunnel.conf"]

EXPOSE 8443