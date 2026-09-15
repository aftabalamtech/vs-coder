FROM codercom/code-server:latest

# CloudDabba routes the public app to the container's port 10000.
# Keep code-server on the same port so HTTP and WebSocket traffic use one
# origin and the platform can proxy the VS Code workbench correctly.
EXPOSE 10000

# The password is intentionally defined here as requested for this deployment.
# For production, prefer PASSWORD/HASHED_PASSWORD as a platform secret.
ENV PASSWORD=marsel
ENV DEFAULT_WORKSPACE=/home/coder/project

RUN mkdir -p /home/coder/project \
    && chown -R coder:coder /home/coder/project

WORKDIR /home/coder/project

# Keep the official code-server entrypoint. It performs the upstream runtime
# setup (fixuid/dumb-init) and starts code-server with password authentication.
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:10000", "--auth", "password", "/home/coder/project"]
