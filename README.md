# VS Coder

A minimal Dockerfile-only deployment wrapper around the official `codercom/code-server` image, configured for CloudDabba.

There is intentionally **no Docker Compose configuration and no custom startup script**. The official code-server container entrypoint is used directly.

## Features

- Official `codercom/code-server:latest` image
- Dockerfile-only deployment
- CloudDabba-compatible container port `10000`
- HTTP and WebSocket traffic on the same origin
- Official upstream container entrypoint
- Browser-based VS Code
- Password authentication
- Workspace at `/home/coder/project`

## Project Structure

```text
vs-coder/
├── Dockerfile
├── .dockerignore
├── .gitignore
└── README.md
```

## How It Works

```text
CloudDabba HTTPS URL
        ↓
CloudDabba reverse proxy
        ↓
Container :10000
        ↓
official /usr/bin/entrypoint.sh
        ↓
code-server
        ↓
/home/coder/project
```

The container listens on `0.0.0.0:10000`. Using the same port for code-server's HTTP and WebSocket traffic avoids the previous workbench disconnect (`WebSocket close with status code 1006`) caused by a port/proxy mismatch.

The repository deliberately keeps the upstream image's startup behavior instead of replacing it with a custom shell script. This preserves the image's `fixuid`, startup hooks, `dumb-init`, and native authentication handling.

## Authentication

The Dockerfile currently contains the requested password for this deployment.

> **Security warning:** this repository is public, so a password committed to the Dockerfile is visible in the repository. For production/public use, remove the hardcoded credential and supply `PASSWORD` or `HASHED_PASSWORD` through the deployment platform's secret/environment-variable settings.

code-server officially supports `PASSWORD` and `HASHED_PASSWORD`; `HASHED_PASSWORD` takes precedence when both are present.

## CloudDabba Deployment

CloudDabba's deployment platform routes applications to the container port it expects for deployed services. This Dockerfile explicitly exposes and binds code-server to port `10000` so the platform can proxy both normal HTTP requests and the code-server WebSocket connection through the same service.

After pushing this change, **redeploy/rebuild the application from the latest `main` commit**. A previously built image will still contain the old `8080` configuration.

## Build

```bash
docker build --no-cache -t vs-coder:latest .
```

## Run Locally

```bash
docker run --name vs-coder \
  -p 10000:10000 \
  vs-coder:latest
```

Open:

```text
http://localhost:10000
```

## Persistent Workspace

For persistent project files:

```bash
docker run --name vs-coder \
  -p 10000:10000 \
  -v vs_coder_workspace:/home/coder/project \
  vs-coder:latest
```

For persistent code-server configuration, attach persistent storage to `/home/coder/.config` when required.

## Troubleshooting

### Workbench shows `WebSocket close with status code 1006`

Make sure CloudDabba has redeployed the **latest commit** and that the running container is using port `10000`. The current Dockerfile binds code-server directly to `0.0.0.0:10000`, so the browser's HTTP and WebSocket traffic reaches the same container endpoint.

Do a fresh redeploy after changing the Dockerfile; do not reuse the old image configured for port `8080`.

### Login says `Incorrect password`

Make sure the latest image has been built. The current Dockerfile sets `PASSWORD=marsel` and uses the official code-server authentication path.

If a persistent `/home/coder/.config` volume contains an old configuration, remove/reset that configuration or provide the intended password through the deployment environment.

### Terminal does not work

The custom startup script has been removed. The official image entrypoint is used directly, including its normal `fixuid` and `dumb-init` setup.

### Port is unreachable

The image listens on:

```text
0.0.0.0:10000
```

The deployment platform must route the public application to container port `10000`.

### Check logs

```bash
docker logs vs-coder
```

## Security

- The current password is committed because it was explicitly requested for this deployment.
- Do not use a committed password for a production/public service.
- Prefer a deployment-platform secret using `PASSWORD` or `HASHED_PASSWORD`.
- Use HTTPS for public deployments.
- Keep the official code-server image updated.

## Upstream

This repository uses the official `codercom/code-server` container image.

## License

This repository contains deployment configuration for code-server. The upstream project's license and terms apply to the code-server software itself.
