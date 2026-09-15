FROM codercom/code-server:latest

EXPOSE 10000

ENV PASSWORD=marsel
ENV DEFAULT_WORKSPACE=/home/coder/project

RUN mkdir -p /home/coder/project \
    && chown -R coder:coder /home/coder/project

WORKDIR /home/coder/project

# CloudDabba supplies PORT dynamically. code-server supports PORT even when
# --bind-addr is present, so do not hard-code a runtime port here.
# Use the exact public origin for the code-server WebSocket origin check.
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--auth", "password", "--trusted-origins", "https://vs-code.clouddabba.dev", "--trusted-origins", "https://clouddabba.dev", "--log", "debug", "/home/coder/project"]
