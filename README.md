# nginx-fancyindex-docker

Minimal Docker image that builds nginx from source with [`ngx-fancyindex`](https://github.com/aperezdc/ngx-fancyindex) compiled in.

## Usage

The image is available at [registry.guzek.uk/nginx/nginx-fancyindex](https://registry.guzek.uk/harbor/projects/3/repositories/nginx-fancyindex/artifacts-tab) and can be pulled without cloning this repository.

### Run directly

```console
docker run --rm -p 8080:80 registry.guzek.uk/nginx/nginx-fancyindex
```

### Run with Docker Compose

```console
wget https://raw.githubusercontent.com/kguzek/nginx-fancyindex-docker/main/compose.yaml
vi compose.yaml # modify the compose file to your liking
docker compose up -d
```

## Manual build

Clone this repository and enter the `nginx-fancyindex-docker` directory.

```console
git clone https://github.com/kguzek/nginx-fancyindex-docker
cd nginx-fancyindex-docker
```

You can now build the image manually.

```console
docker build -t nginx-fancyindex .
```

Optional build arguments:

```console
docker build \
  --build-arg NGINX_VERSION=1.26.3 \
  --build-arg FANCYINDEX_REF=master \
  -t nginx-fancyindex .
```

### Run built image

```console
docker run --rm -p 8080:80 nginx-fancyindex
```

Open <http://localhost:8080>.

To serve your own directory:

```console
docker run --rm -p 8080:80 \
  -v "$PWD/html:/usr/share/nginx/html:ro" \
  nginx-fancyindex
```

#### With Docker Compose

Replace the `image` field in [compose.yaml](compose.yaml#L3) with `build`:

```diff
-    image: registry.guzek.uk/nginx/nginx-fancyindex:latest
+    build: .
```

This will now use the local Dockerfile instead of pulling the remote image.

```console
docker compose up --build
```
