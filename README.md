# Code Server Deploy

A Docker-based deployment wrapper for [code-server](https://github.com/coder/code-server), allowing you to run VS Code in your browser with persistent configuration, data, and workspace storage.

## Features

* Run VS Code in a web browser
* Docker-based deployment
* Docker Compose support
* Persistent workspace
* Persistent code-server configuration
* Persistent code-server data
* Environment-variable based configuration
* Optional sudo access
* Optional reverse-proxy domain configuration
* Automatic container restart
* Health check
* Easy deployment and updates

---

## Requirements

Before deploying, make sure you have:

* Docker installed
* Docker Compose v2 installed
* A server or machine where Docker can run
* A browser for accessing code-server

Check your installation:

```bash
docker --version
docker compose version
```

---

## Project Structure

```text
code-server-deploy/
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .dockerignore
├── .gitignore
└── README.md
```

---

# Quick Start

## 1. Clone the repository

```bash
git clone https://github.com/aftabalamtech/code-server-deploy.git
cd code-server-deploy
```

## 2. Create the environment file

Copy the example configuration:

```bash
cp .env.example .env
```

On Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

---

## 3. Configure `.env`

Open the `.env` file:

```bash
nano .env
```

At minimum, configure authentication.

You must provide **one of these two variables**:

```env
PASSWORD=your-password
```

**OR**

```env
HASHED_PASSWORD=your-hashed-password
```

Do not leave both authentication variables empty.

For production deployments, prefer a properly generated hashed password where supported.

---

# Environment Variables

The following variables are supported by the deployment configuration.

| Variable             | Required  | Default               | Description                                         |
| -------------------- | --------- | --------------------- | --------------------------------------------------- |
| `CONTAINER_NAME`     | Optional  | `code-server`         | Name of the Docker container.                       |
| `PORT`               | Optional  | `8080`                | Host port exposed for code-server.                  |
| `PASSWORD`           | Required* | —                     | Plain-text code-server authentication password.     |
| `HASHED_PASSWORD`    | Required* | —                     | Hashed code-server authentication password.         |
| `SUDO_PASSWORD`      | Optional  | —                     | Password used for sudo access inside the container. |
| `SUDO_PASSWORD_HASH` | Optional  | —                     | Hashed sudo password where supported.               |
| `PROXY_DOMAIN`       | Optional  | —                     | Domain used when deploying behind a reverse proxy.  |
| `DEFAULT_WORKSPACE`  | Optional  | `/home/coder/project` | Workspace directory opened by code-server.          |

### Authentication requirement

`PASSWORD` and `HASHED_PASSWORD` are alternatives.

You must configure **at least one**:

```env
PASSWORD=your-password
```

or:

```env
HASHED_PASSWORD=your-hashed-password
```

Therefore:

* `PASSWORD` → **Required if `HASHED_PASSWORD` is not configured**
* `HASHED_PASSWORD` → **Required if `PASSWORD` is not configured**
* Both empty → **Not valid for an authenticated deployment**
* Both configured → avoid ambiguity; use one authentication method

> For production, prefer the hashed-password method where supported by the installed code-server version.

---

# Complete `.env` Configuration

The following is a complete example:

```env
# ============================================================
# Code Server Deployment Configuration
# Copy this file to .env before starting the container.
# ============================================================


# ------------------------------------------------------------
# Container
# ------------------------------------------------------------

# OPTIONAL
# Docker container name.
CONTAINER_NAME=code-server


# ------------------------------------------------------------
# Network
# ------------------------------------------------------------

# OPTIONAL
# Host port exposed by Docker.
#
# Default:
# 8080
PORT=8080


# ------------------------------------------------------------
# Authentication
# ------------------------------------------------------------

# REQUIRED*
# Plain-text password.
#
# Configure this OR HASHED_PASSWORD.
#
# For production, prefer HASHED_PASSWORD where supported.
PASSWORD=


# REQUIRED*
# Hashed code-server password.
#
# Configure this OR PASSWORD.
HASHED_PASSWORD=


# ------------------------------------------------------------
# Sudo
# ------------------------------------------------------------

# OPTIONAL
# Password for sudo access inside the container.
#
# Leave empty if sudo access is not required.
SUDO_PASSWORD=


# OPTIONAL
# Hashed sudo password where supported.
SUDO_PASSWORD_HASH=


# ------------------------------------------------------------
# Reverse Proxy
# ------------------------------------------------------------

# OPTIONAL
# Domain used when code-server is deployed behind
# a reverse proxy.
#
# Example:
# PROXY_DOMAIN=code.example.com
PROXY_DOMAIN=


# ------------------------------------------------------------
# Workspace
# ------------------------------------------------------------

# OPTIONAL
# Default workspace directory opened by code-server.
#
# This directory is persisted using the Docker workspace volume.
DEFAULT_WORKSPACE=/home/coder/project
```

---

# Deploy

After configuring `.env`, build and start the container:

```bash
docker compose up -d --build
```

Check the container:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f
```

---

# Access Code Server

If running locally:

```text
http://localhost:8080
```

If running on a remote server:

```text
http://SERVER_IP:8080
```

For example:

```text
http://203.0.113.10:8080
```

The actual address depends on your server's IP and configured `PORT`.

---

# Docker Compose Configuration

The deployment uses Docker Compose.

The default service is:

```yaml
services:
  code-server:
```

The container exposes port `8080` internally.

The host port is controlled by:

```env
PORT=8080
```

For example:

```env
PORT=3000
```

will expose code-server through:

```text
http://localhost:3000
```

---

# Persistent Storage

The deployment uses Docker named volumes so that your workspace and code-server data survive container recreation.

## Configuration

```text
/home/coder/.config
```

is persisted using:

```text
code_server_config
```

## Code Server Data

```text
/home/coder/.local/share/code-server
```

is persisted using:

```text
code_server_data
```

## Workspace

```text
/home/coder/project
```

is persisted using:

```text
workspace
```

Therefore, removing and recreating the container does not automatically remove your persistent workspace data.

---

# Volumes

View Docker volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect workspace
```

> Do not delete the persistent volumes unless you intentionally want to remove the stored data.

---

# Stop the Deployment

Stop the containers without removing them:

```bash
docker compose stop
```

---

# Start the Deployment Again

```bash
docker compose start
```

---

# Restart the Deployment

```bash
docker compose restart
```

---

# Stop and Remove Containers

```bash
docker compose down
```

This removes the containers and network created by Compose but does **not** remove the named volumes by default.

---

# Remove Containers and Persistent Data

Use this only when you intentionally want to delete stored code-server data and workspace data:

```bash
docker compose down -v
```

> **Warning:** `-v` removes the Compose-managed volumes. Any data stored exclusively in those volumes can be lost.

---

# Updating Code Server

Pull the latest configured image and recreate the container:

```bash
docker compose pull
docker compose up -d
```

If the Dockerfile needs to be rebuilt:

```bash
docker compose up -d --build
```

Check the running containers:

```bash
docker compose ps
```

---

# Viewing Logs

Follow live logs:

```bash
docker compose logs -f
```

Only the code-server service:

```bash
docker compose logs -f code-server
```

Show recent logs:

```bash
docker compose logs --tail=100 code-server
```

---

# Custom Container Name

By default:

```env
CONTAINER_NAME=code-server
```

You can change it:

```env
CONTAINER_NAME=my-code-server
```

---

# Custom Port

The default host port is:

```env
PORT=8080
```

To expose code-server on port `3000`:

```env
PORT=3000
```

Then access:

```text
http://localhost:3000
```

The container itself continues to listen on port `8080`.

---

# Authentication

Authentication is controlled through the environment configuration.

## Password Authentication

Example:

```env
PASSWORD=ChangeThisToAStrongPassword
```

Use a strong, unique password.

Do not use passwords such as:

```text
123456
password
admin
12345678
```

---

## Hashed Password

If using a hashed password:

```env
HASHED_PASSWORD=your-hashed-password
```

Use the password-hashing mechanism documented for the version of code-server you are deploying.

Because authentication configuration can vary between code-server versions, always verify the supported configuration for the exact image/version being deployed.

---

# Sudo Access

Sudo access is optional.

If your deployment requires sudo:

```env
SUDO_PASSWORD=your-sudo-password
```

If supported by your code-server image/version, a hashed sudo password can be used:

```env
SUDO_PASSWORD_HASH=your-hashed-sudo-password
```

If sudo access is not required, leave both variables empty.

---

# Reverse Proxy

`PROXY_DOMAIN` is optional.

Example:

```env
PROXY_DOMAIN=code.example.com
```

A reverse proxy can be placed in front of code-server to provide:

* HTTPS
* Custom domain
* TLS certificates
* Access control
* Additional security policies

A typical production architecture is:

```text
Internet
   │
   ▼
Reverse Proxy
   │
   ▼
code-server
   │
   ▼
Workspace
```

If you are not using a reverse proxy, leave:

```env
PROXY_DOMAIN=
```

---

# Workspace

The default workspace is:

```env
DEFAULT_WORKSPACE=/home/coder/project
```

The directory is backed by the persistent Docker volume:

```text
workspace
```

This allows your project files to remain available after container restarts and recreation.

---

# Security Recommendations

For production deployments:

1. Use a strong authentication password.
2. Prefer hashed authentication credentials where supported.
3. Never commit `.env` to Git.
4. Do not publish passwords in `README.md`.
5. Use HTTPS when exposing code-server to the Internet.
6. Prefer a reverse proxy, VPN, or private network for sensitive deployments.
7. Restrict firewall access to the required ports.
8. Keep Docker and the code-server image updated.
9. Avoid exposing the Docker socket unless it is explicitly required.
10. Back up important workspace data.

---

# Protecting `.env`

The `.gitignore` file excludes environment files:

```gitignore
.env
.env.local
.env.*.local
```

Never force-add your production `.env`:

```bash
git add -f .env
```

unless you fully understand the security implications.

---

# Troubleshooting

## Container is not starting

Check:

```bash
docker compose ps
```

Then:

```bash
docker compose logs --tail=200 code-server
```

---

## Port already in use

If port `8080` is already being used, change:

```env
PORT=8080
```

to another available port:

```env
PORT=3000
```

Then recreate:

```bash
docker compose up -d
```

---

## Check the container

```bash
docker ps
```

---

## Enter the container

```bash
docker exec -it code-server bash
```

If you changed `CONTAINER_NAME`, use the configured container name instead.

---

# Production Deployment Checklist

Before exposing the service publicly:

* [ ] Docker is installed and updated
* [ ] Docker Compose is available
* [ ] `PASSWORD` or `HASHED_PASSWORD` is configured
* [ ] Password is strong and unique
* [ ] `.env` is not committed to Git
* [ ] Firewall is configured
* [ ] HTTPS is enabled
* [ ] Reverse proxy is configured if required
* [ ] Workspace persistence has been verified
* [ ] Important data is backed up
* [ ] Unnecessary sudo access is disabled

---

# Configuration Summary

### Required

**One authentication method is required:**

```env
PASSWORD=...
```

**OR**

```env
HASHED_PASSWORD=...
```

### Optional

```env
CONTAINER_NAME=
PORT=
SUDO_PASSWORD=
SUDO_PASSWORD_HASH=
PROXY_DOMAIN=
DEFAULT_WORKSPACE=
```

### Defaults

```env
CONTAINER_NAME=code-server
PORT=8080
DEFAULT_WORKSPACE=/home/coder/project
```

---

# Upstream Project

This repository is a deployment wrapper around the upstream [code-server](https://github.com/coder/code-server) project.

For official code-server documentation, configuration options, supported environment variables, and version-specific behavior, refer to the upstream project documentation.

---

# License

This repository contains deployment configuration for code-server.

The upstream code-server project is maintained by Coder and is subject to its own license and terms.

Refer to the upstream project for its current licensing information.
