ARG NGINX_VERSION=1.26.3
ARG FANCYINDEX_REF=master

FROM alpine:3.20 AS build

ARG NGINX_VERSION
ARG FANCYINDEX_REF

RUN apk add --no-cache \
    build-base \
    git \
    linux-headers \
    pcre2-dev \
    tar \
    wget \
    zlib-dev

WORKDIR /tmp/build

RUN wget -O nginx.tar.gz "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && tar -xzf nginx.tar.gz \
    && git clone --depth 1 --branch "${FANCYINDEX_REF}" https://github.com/aperezdc/ngx-fancyindex.git

WORKDIR /tmp/build/nginx-${NGINX_VERSION}

RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/dev/stderr \
    --http-log-path=/dev/stdout \
    --pid-path=/tmp/nginx.pid \
    --lock-path=/tmp/nginx.lock \
    --http-client-body-temp-path=/tmp/client_temp \
    --http-proxy-temp-path=/tmp/proxy_temp \
    --http-fastcgi-temp-path=/tmp/fastcgi_temp \
    --http-uwsgi-temp-path=/tmp/uwsgi_temp \
    --http-scgi-temp-path=/tmp/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-pcre-jit \
    --without-http_empty_gif_module \
    --without-http_geo_module \
    --without-http_map_module \
    --without-http_memcached_module \
    --without-http_split_clients_module \
    --without-http_ssi_module \
    --without-http_upstream_hash_module \
    --without-http_upstream_ip_hash_module \
    --without-http_upstream_keepalive_module \
    --without-http_upstream_least_conn_module \
    --without-http_upstream_random_module \
    --without-http_upstream_zone_module \
    --add-module=/tmp/build/ngx-fancyindex \
    && make -j"$(nproc)" \
    && make install \
    && strip /usr/sbin/nginx

FROM alpine:3.20

RUN apk add --no-cache pcre2 zlib \
    && addgroup -S nginx \
    && adduser -S -D -H -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && mkdir -p /etc/nginx/conf.d /etc/nginx/server.d /etc/nginx/location.d /usr/share/nginx/html /var/cache/nginx \
    && chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx

COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build /etc/nginx/mime.types /etc/nginx/mime.types
COPY nginx.conf /etc/nginx/nginx.conf
COPY html/ /usr/share/nginx/html/

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
