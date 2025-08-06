FROM ghcr.io/yrutschle/sslh:latest

EXPOSE 8443

CMD ["--foreground", "--listen=0.0.0.0:8443", "--tls=captain-nginx:443", "--anyprot=srv-captain--test-deployment-stunnel:443"]