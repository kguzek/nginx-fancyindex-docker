# nginx-fancyindex-docker

Minimal Docker image that builds nginx from source with [`ngx-fancyindex`](https://github.com/aperezdc/ngx-fancyindex) compiled in.

## Usage

The image is available at [registry.guzek.uk/nginx/nginx-fancyindex](https://registry.guzek.uk/harbor/projects/3/repositories/nginx-fancyindex/artifacts-tab) and can be pulled without cloning this repository.

### Run directly

```sh
docker run --rm -p 8080:80 registry.guzek.uk/nginx/nginx-fancyindex
```

To serve your own directory:

```sh
docker run --rm -p 8080:80 \
  -v "$PWD/html:/usr/share/nginx/html:ro" \
  registry.guzek.uk/nginx/nginx-fancyindex
```

To customize nginx directives without rebuilding the image, bind-mount `.conf` snippets into one of the included configuration directories:

- `/etc/nginx/conf.d/*.conf` for directives inside the `http` block
- `/etc/nginx/server.d/*.conf` for directives inside the default `server` block
- `/etc/nginx/location.d/*.conf` for directives inside the default `/` location

For example, create `location.conf`:

```nginx
fancyindex_exact_size on;
fancyindex_name_length 255;
```

Then run:

```sh
docker run --rm -p 8080:80 \
  -v "$PWD/html:/usr/share/nginx/html:ro" \
  -v "$PWD/location.conf:/etc/nginx/location.d/custom.conf:ro" \
  registry.guzek.uk/nginx/nginx-fancyindex
```

You can still replace the whole nginx configuration if needed:

```sh
docker run --rm -p 8080:80 \
  -v "$PWD/nginx.conf:/etc/nginx/nginx.conf:ro" \
  registry.guzek.uk/nginx/nginx-fancyindex
```

### Run with Docker Compose

```sh
wget https://raw.githubusercontent.com/kguzek/nginx-fancyindex-docker/main/compose.yaml
vi compose.yaml # modify the compose file to your liking
docker compose up -d
```

Example compose file with content and nginx directive snippets mounted:

```yaml
services:
  nginx-fancyindex:
    image: registry.guzek.uk/nginx/nginx-fancyindex:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
      - ./location.conf:/etc/nginx/location.d/custom.conf:ro
```

## Manual build

Clone this repository and enter the `nginx-fancyindex-docker` directory.

```sh
git clone https://github.com/kguzek/nginx-fancyindex-docker
cd nginx-fancyindex-docker
```

You can now build the image manually.

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

### Run built image

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

To customize nginx directives without rebuilding again, use the same include directories as the hosted image:

```sh
docker run --rm -p 8080:80 \
  -v "$PWD/html:/usr/share/nginx/html:ro" \
  -v "$PWD/location.conf:/etc/nginx/location.d/custom.conf:ro" \
  nginx-fancyindex
```

Snippet mounts are loaded from:

- `/etc/nginx/conf.d/*.conf` inside the `http` block
- `/etc/nginx/server.d/*.conf` inside the default `server` block
- `/etc/nginx/location.d/*.conf` inside the default `/` location

#### With Docker Compose

Replace the `image` field in [compose.yaml](compose.yaml#L3) with `build`:

```diff
-    image: registry.guzek.uk/nginx/nginx-fancyindex:latest
+    build: .
```

This will now use the local Dockerfile instead of pulling the remote image.

```sh
docker compose up --build
```

Local compose usage can mount directive snippets in the same way:

```yaml
services:
  nginx-fancyindex:
    build: .
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
      - ./location.conf:/etc/nginx/location.d/custom.conf:ro
```
