# nginx-fancyindex-docker

Minimal Docker image that builds nginx from source with [`ngx-fancyindex`](https://github.com/aperezdc/ngx-fancyindex) compiled in.

## Build

```sh
docker build -t nginx-fancyindex .
```

Optional build arguments:

```sh
docker build \
  --build-arg NGINX_VERSION=1.26.3 \
  --build-arg FANCYINDEX_REF=master \
  -t nginx-fancyindex .
```

## Run

```sh
docker run --rm -p 8080:80 nginx-fancyindex
```

Open <http://localhost:8080>.

To serve your own directory:

```sh
docker run --rm -p 8080:80 \
  -v "$PWD/html:/usr/share/nginx/html:ro" \
  nginx-fancyindex
```

## Compose

```sh
docker compose up --build
```
