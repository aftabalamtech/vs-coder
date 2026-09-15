FROM codercom/code-server:latest

# Keep the official code-server image entrypoint and runtime intact.
# The password is intentionally defined here as requested so the container
# works without requiring a separate runtime environment variable.
ENV PASSWORD=marsel
ENV DEFAULT_WORKSPACE=/home/coder/project

RUN mkdir -p /home/coder/project \
    && chown -R coder:coder /home/coder/project

WORKDIR /home/coder/project

# Use the official entrypoint, but provide deployment-safe bind/port and the
# workspace explicitly. The official entrypoint handles fixuid, dumb-init,
# startup hooks, and then launches code-server.
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "--auth", "password", "/home/coder/project"]
