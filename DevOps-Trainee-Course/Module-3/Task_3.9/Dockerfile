FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y nginx

RUN mkdir -p /var/log/nginx/external

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /etc/nginx

VOLUME /var/lib/nginx

ENTRYPOINT ["nginx"]

CMD ["-g", "daemon off;"]

