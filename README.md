# VS Coder

A Docker-based deployment wrapper for [code-server](https://github.com/coder/code-server).

This repository is intentionally **Dockerfile-only** for deployment. There is no Docker Compose configuration. The container starts through `start.sh`, which launches code-server directly.

## Features

- Run VS Code in a browser with code-server
- Deployment through a standard Dockerfile
- `start.sh` used as the container entrypoint
- Configurable workspace directory
- Configurable bind address
- Optional code-server environment variables
- Persistent storage can be attached by the deployment platform

## Requirements

- Docker
- A deployment platform that can build and run a Dockerfile
- A browser to access code-server

Check Docker:

```bash
docker --version
```

## Project Structure

```text
vs-coder/
├── Dockerfile
├── start.sh
├── .dockerignore
├── .gitignore
└── README.md
```

## How It Works

The deployment flow is:

```text
Docker build
    ↓
Dockerfile
    ↓
start.sh
    ↓
code-server
    ↓
/home/coder/project
```

The Dockerfile installs the startup script and makes it the container entrypoint. `start.sh` starts code-server on `0.0.0.0:8080` by default.

## Dockerfile

The image is based on the upstream `codercom/code-server:latest` image.

The container exposes port `8080` and starts `start.sh` automatically.

## Environment Variables

All variables below are **environment variables for the running container**. How you provide them depends on your deployment platform.

| Variable | Required | Default | Description |
|---|---|---|---|
| `PASSWORD` | Optional* | — | Plain-text code-server authentication password. |
| `HASHED_PASSWORD` | Optional* | — | Hashed code-server authentication password. |
| `SUDO_PASSWORD` | Optional | — | Password for sudo access, when supported by the image/configuration. |
| `SUDO_PASSWORD_HASH` | Optional | — | Hashed sudo password, when supported. |
| `PROXY_DOMAIN` | Optional | — | Domain used for code-server when running behind a reverse proxy. |
| `DEFAULT_WORKSPACE` | Optional | `/home/coder/project` | Workspace directory opened by `start.sh`. |
| `CODE_SERVER_BIND_ADDR` | Optional | `0.0.0.0:8080` | Address and port used by code-server. |

### Authentication requirement

`PASSWORD` and `HASHED_PASSWORD` are alternative authentication mechanisms.

For an authenticated deployment, configure **at least one** of them according to the code-server version being used:

```env
PASSWORD=your-password
```

or:

```env
HASHED_PASSWORD=your-hashed-password
```

Do not publish real passwords in this repository.

> **Important:** code-server configuration and supported environment variables can vary by version. Verify the exact upstream documentation for the image tag you deploy.

## Complete Environment Example

```env
# ------------------------------------------------------------
# Authentication
# ------------------------------------------------------------

# OPTIONAL* — configure this OR HASHED_PASSWORD
PASSWORD=

# OPTIONAL* — configure this OR PASSWORD
HASHED_PASSWORD=

# ------------------------------------------------------------
# Sudo
# ------------------------------------------------------------

# OPTIONAL
SUDO_PASSWORD=

# OPTIONAL
SUDO_PASSWORD_HASH=

# ------------------------------------------------------------
# Reverse Proxy
# ------------------------------------------------------------

# OPTIONAL
# Example: code.example.com
PROXY_DOMAIN=

# ------------------------------------------------------------
# Workspace
# ------------------------------------------------------------

# OPTIONAL
DEFAULT_WORKSPACE=/home/coder/project

# ------------------------------------------------------------
# Server bind address
# ------------------------------------------------------------

# OPTIONAL
CODE_SERVER_BIND_ADDR=0.0.0.0:8080
```

## Build the Image

From the repository root:

```bash
docker build -t vs-coder:latest .
```

## Run the Container

Basic example:

```bash
docker run --name vs-coder \
  -p 8080:8080 \
  -e PASSWORD='change-this-password' \
  vs-coder:latest
```

Then open:

```text
http://localhost:8080
```

For a remote server, replace `localhost` with the server address and make sure the deployment platform/firewall exposes the selected port.

## Custom Workspace

Set a different workspace directory:

```bash
docker run --name vs-coder \
  -p 8080:8080 \
  -e PASSWORD='change-this-password' \
  -e DEFAULT_WORKSPACE='/home/coder/project' \
  vs-coder:latest
```

`start.sh` creates the selected workspace directory if it does not already exist.

## Persistent Storage

The container filesystem is ephemeral unless your deployment platform or Docker runtime attaches persistent storage.

To keep projects across container recreation, mount a volume to the workspace:

```bash
docker run --name vs-coder \
  -p 8080:8080 \
  -e PASSWORD='change-this-password' \
  -v vs_coder_workspace:/home/coder/project \
  vs-coder:latest
```

For persistent code-server configuration/data, attach storage according to the paths required by the code-server version you deploy.

## Start Script

`start.sh` performs three jobs:

1. Reads `CODE_SERVER_BIND_ADDR` or uses `0.0.0.0:8080`.
2. Reads `DEFAULT_WORKSPACE` or uses `/home/coder/project`.
3. Creates the workspace directory and executes code-server.

The script uses `exec`, so code-server becomes the main container process and receives Docker signals correctly.

## Deployment Platforms

This repository is suitable for platforms that support **Dockerfile-based deployments**.

The platform should:

1. Detect the repository's `Dockerfile`.
2. Build the image.
3. Run the image.
4. Expose the configured application port.
5. Provide environment variables through the platform's environment configuration.

No `docker-compose.yml` is required.

## Port Configuration

The default code-server listener is:

```text
0.0.0.0:8080
```

This is controlled by:

```env
CODE_SERVER_BIND_ADDR=0.0.0.0:8080
```

If your deployment platform requires a different runtime port, set this variable accordingly, for example:

```env
CODE_SERVER_BIND_ADDR=0.0.0.0:3000
```

Your deployment platform must also expose the same application port.

## Reverse Proxy

When using a reverse proxy or custom domain, set:

```env
PROXY_DOMAIN=code.example.com
```

A typical production path is:

```text
Internet
   ↓
HTTPS / Reverse Proxy
   ↓
code-server container
   ↓
Workspace
```

Use HTTPS whenever code-server is reachable over a public network.

## Security

- Use a strong, unique password.
- Do not commit `.env` files or real credentials.
- Prefer a hashed authentication method where supported by your exact code-server version.
- Use HTTPS for public deployments.
- Restrict access with a firewall, private network, VPN, or reverse proxy when appropriate.
- Keep the code-server image updated.
- Do not expose the Docker socket unless there is a specific operational requirement.

## Troubleshooting

### Container starts but the service is unreachable

Check the container:

```bash
docker ps
```

Check logs:

```bash
docker logs vs-coder
```

Verify that the exposed runtime port matches `CODE_SERVER_BIND_ADDR` and the deployment platform's port configuration.

### Permission or workspace errors

Verify that `DEFAULT_WORKSPACE` points to a writable location for the `coder` user.

### Authentication does not work

Verify the authentication variables supported by the exact code-server version being deployed. Do not assume variables from another image or version are compatible.

## Updating

Pull the latest repository changes and rebuild the image:

```bash
git pull
docker build -t vs-coder:latest .
```

Then recreate the running container using your deployment platform or Docker runtime.

## Upstream Project

This repository is a deployment wrapper around [code-server](https://github.com/coder/code-server).

For version-specific configuration, supported environment variables, authentication behavior, and official documentation, use the upstream code-server project.

## License

This repository contains deployment configuration for code-server. The upstream project's license and terms apply to the code-server software itself.
