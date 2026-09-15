# VS Coder

A minimal Dockerfile-only deployment wrapper around the official `codercom/code-server` image.

There is intentionally **no Docker Compose configuration and no custom startup script**. The official code-server container entrypoint is used directly.

## Features

- Official `codercom/code-server:latest` image
- Dockerfile-only deployment
- Official upstream container entrypoint
- Browser-based VS Code
- Password authentication
- Workspace at `/home/coder/project`
- Port `8080` bound to `0.0.0.0`

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
Docker build
    ↓
Dockerfile
    ↓
codercom/code-server:latest
    ↓
official /usr/bin/entrypoint.sh
    ↓
code-server
    ↓
/home/coder/project
```

The repository deliberately keeps the upstream image's startup behavior instead of replacing it with a custom shell script. This preserves the image's `fixuid`, startup hooks, `dumb-init`, and native authentication handling.

## Authentication

The Dockerfile currently contains the requested password for this deployment.

> **Security warning:** this repository is public, so a password committed to the Dockerfile is visible in the repository. For production/public use, remove the hardcoded credential and supply `PASSWORD` or `HASHED_PASSWORD` through the deployment platform's secret/environment-variable settings.

code-server officially supports `PASSWORD` and `HASHED_PASSWORD`; `HASHED_PASSWORD` takes precedence when both are present.

## Build

```bash
docker build --no-cache -t vs-coder:latest .
```

The `--no-cache` option is recommended after changing authentication or the Dockerfile so an old image layer cannot be reused.

## Run

```bash
docker run --name vs-coder \
  -p 8080:8080 \
  vs-coder:latest
```

Open:

```text
http://localhost:8080
```

## Persistent Workspace

For persistent project files:

```bash
docker run --name vs-coder \
  -p 8080:8080 \
  -v vs_coder_workspace:/home/coder/project \
  vs-coder:latest
```

For persistent code-server configuration, attach persistent storage to `/home/coder/.config` when required.

## Deployment

The deployment platform only needs to:

1. Build the repository's `Dockerfile`.
2. Run the resulting image.
3. Expose container port `8080`.

No Compose file is required.

## Troubleshooting

### Login says `Incorrect password`

Make sure the platform has built the **latest commit** and perform a clean rebuild/redeploy. Do not reuse an old Docker image.

For a local build:

```bash
docker build --no-cache -t vs-coder:latest .
docker rm -f vs-coder 2>/dev/null || true
docker run --name vs-coder -p 8080:8080 vs-coder:latest
```

The current Dockerfile uses the official code-server entrypoint directly, so there is no custom authentication script that can accidentally replace or reinterpret the password.

### Terminal does not work

The custom startup script has been removed. The official image entrypoint is used directly, including its normal `fixuid` and `dumb-init` setup.

### Port is unreachable

The image is configured to listen on:

```text
0.0.0.0:8080
```

Your deployment platform must expose container port `8080`.

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

This repository uses the official `codercom/code-server` container image. Current code-server documentation confirms the official Docker image supports `amd64` and `arm64`, and documents `PASSWORD`/`HASHED_PASSWORD` authentication.

## License

This repository contains deployment configuration for code-server. The upstream project's license and terms apply to the code-server software itself.
