# VS Coder

A Dockerfile-only deployment wrapper for [code-server](https://github.com/coder/code-server).

There is intentionally **no Docker Compose configuration**. The container starts through `start.sh`.

## Features

- Run VS Code in a browser with code-server
- Dockerfile-only deployment
- `start.sh` as the container entrypoint
- Password or hashed-password authentication
- Configurable workspace directory
- Configurable bind address
- Persistent storage can be attached by the deployment platform

## Requirements

- Docker
- A platform that supports Dockerfile-based deployments
- A browser

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

The custom `start.sh` entrypoint creates the code-server configuration from the runtime environment and then starts code-server.

## Authentication

The running container must receive **one** of these variables:

```env
PASSWORD=your-password
```

or:

```env
HASHED_PASSWORD=your-argon2-hash
```

`HASHED_PASSWORD` takes precedence if both are supplied.

The startup script writes the selected credential to:

```text
/home/coder/.config/code-server/config.yaml
```

This is important because this repository uses a custom entrypoint instead of the upstream image entrypoint. The custom script therefore cannot rely on image-specific processing of `PASSWORD`/`HASHED_PASSWORD`.

If neither authentication variable is supplied, the container exits with an explicit error instead of starting with an unknown password.

For hashed passwords, use the code-server-supported Argon2 format documented by the upstream project.

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `PASSWORD` | Required* | — | Plain-text code-server password. Configure this OR `HASHED_PASSWORD`. |
| `HASHED_PASSWORD` | Required* | — | Argon2 hashed code-server password. Takes precedence over `PASSWORD`. |
| `DEFAULT_WORKSPACE` | Optional | `/home/coder/project` | Workspace directory opened by code-server. |
| `CODE_SERVER_BIND_ADDR` | Optional | `0.0.0.0:8080` | Address and port on which code-server listens. |
| `CODE_SERVER_CONFIG_DIR` | Optional | `/home/coder/.config/code-server` | Directory containing the generated code-server configuration. |

`*` At least one of `PASSWORD` or `HASHED_PASSWORD` is required.

### Example environment

```env
# REQUIRED: configure this OR HASHED_PASSWORD
PASSWORD=change-this-password

# REQUIRED alternative: Argon2 hash
HASHED_PASSWORD=

# OPTIONAL
DEFAULT_WORKSPACE=/home/coder/project

# OPTIONAL
CODE_SERVER_BIND_ADDR=0.0.0.0:8080

# OPTIONAL
CODE_SERVER_CONFIG_DIR=/home/coder/.config/code-server
```

Do not commit real credentials to Git.

## Build the Image

```bash
docker build -t vs-coder:latest .
```

## Run the Container

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

For a remote deployment, expose the same application port through the deployment platform or firewall.

## Persistent Workspace

The container filesystem is ephemeral unless persistent storage is attached.

Example:

```bash
docker run --name vs-coder \
  -p 8080:8080 \
  -e PASSWORD='change-this-password' \
  -v vs_coder_workspace:/home/coder/project \
  vs-coder:latest
```

For persistent code-server configuration, attach storage to `/home/coder/.config` or the configured `CODE_SERVER_CONFIG_DIR`.

## Port Configuration

Default:

```env
CODE_SERVER_BIND_ADDR=0.0.0.0:8080
```

If your deployment platform requires port `3000`:

```env
CODE_SERVER_BIND_ADDR=0.0.0.0:3000
```

The platform must expose the same runtime port.

## Start Script

`start.sh`:

1. Reads `PASSWORD` or `HASHED_PASSWORD`.
2. Gives `HASHED_PASSWORD` precedence when both are present.
3. Generates the code-server `config.yaml`.
4. Reads `DEFAULT_WORKSPACE`.
5. Reads `CODE_SERVER_BIND_ADDR`.
6. Starts code-server with the generated configuration.

Passwords are written with restrictive file permissions and single quotes are escaped for YAML.

## Deployment Platforms

This repository is designed for platforms that:

1. Detect the `Dockerfile`.
2. Build the image.
3. Run the image.
4. Provide environment variables.
5. Expose the configured application port.

No `docker-compose.yml` is required.

## Troubleshooting

### Login says `Incorrect password`

First verify that the deployment has the expected environment variable:

```env
PASSWORD=your-actual-password
```

Then **rebuild/redeploy the container** so the updated `start.sh` is included.

The container now generates its own code-server config at startup, so an old config containing a literal value such as `$PASSWORD` will be replaced when the container starts with a real `PASSWORD` or `HASHED_PASSWORD`.

Check logs:

```bash
docker logs vs-coder
```

### Container exits immediately

Check logs:

```bash
docker logs vs-coder
```

If neither authentication variable is configured, the startup script intentionally exits with:

```text
ERROR: Set PASSWORD or HASHED_PASSWORD in the container environment.
```

### Port is unreachable

Make sure `CODE_SERVER_BIND_ADDR` and the deployment platform's exposed port match.

### Workspace permission error

Make sure `DEFAULT_WORKSPACE` points to a location writable by the `coder` user.

## Security

- Use a strong, unique password.
- Prefer `HASHED_PASSWORD` for production where practical.
- Never commit `.env` files or real credentials.
- Use HTTPS for public deployments.
- Restrict access with a firewall, VPN, private network, or reverse proxy when appropriate.
- Keep the code-server image updated.
- Do not expose the Docker socket unless explicitly required.

## Updating

Pull the latest repository changes and rebuild:

```bash
git pull
docker build -t vs-coder:latest .
```

Then recreate the running container through your deployment platform.

## Upstream Project

This repository is a deployment wrapper around [code-server](https://github.com/coder/code-server).

For current configuration behavior, authentication details, and version-specific documentation, refer to the upstream project.

## License

This repository contains deployment configuration for code-server. The upstream project's license and terms apply to the code-server software itself.
