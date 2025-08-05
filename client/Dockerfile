FROM webratio/ant:1.10.1 AS builder

# Install system fonts and font utilities
RUN apt-get update && apt-get install -y \
    fontconfig \
    fonts-liberation \
    fonts-dejavu \
    fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

# Create fonts directory and copy custom fonts
RUN mkdir -p /usr/share/fonts/truetype/custom
COPY fonts/*.ttf /usr/share/fonts/truetype/custom/

# Update font cache
RUN fc-cache -fv

COPY . /client
WORKDIR /client
RUN chmod +x flex/bin/fcsh

# Generate font snapshot for Flex SDK
RUN cd flex && java -cp lib/mxmlc.jar flex2.tools.FontSnapshot /usr/share/fonts/truetype/custom/ > frameworks/localFonts.ser

RUN ant

FROM nginx:1.15-alpine

COPY --from=builder /client/bin/* /client/bin/
COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./website /usr/share/nginx/html/

CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80