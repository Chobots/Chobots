FROM webratio/ant:1.10.1 AS builder

# Build arguments for RTMP configuration
ARG RTMP_USE_TLS=false
ARG RTMP_HOSTNAME=localhost
ARG RTMP_PORT=8935

# Set environment variables
ENV RTMP_USE_TLS=$RTMP_USE_TLS
ENV RTMP_HOSTNAME=$RTMP_HOSTNAME
ENV RTMP_PORT=$RTMP_PORT

COPY . /client
WORKDIR /client

# Process the ActionScript file to inject RTMP configuration
RUN sed -i "s/\${RTMP_USE_TLS}/$RTMP_USE_TLS/g" kavalok_core/src/com/kavalok/login/LoginManager.as && \
    sed -i "s/\${RTMP_HOSTNAME}/$RTMP_HOSTNAME/g" kavalok_core/src/com/kavalok/login/LoginManager.as && \
    sed -i "s/\${RTMP_PORT}/$RTMP_PORT/g" kavalok_core/src/com/kavalok/login/LoginManager.as

RUN chmod +x flex/bin/fcsh
RUN ant

FROM nginx:1.15-alpine

COPY --from=builder /client/bin/* /client/bin/
COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./website /usr/share/nginx/html/

CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80