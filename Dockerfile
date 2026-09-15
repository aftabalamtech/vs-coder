FROM codercom/code-server:latest

EXPOSE 10000

ENV PASSWORD=marsel
ENV DEFAULT_WORKSPACE=/home/coder/project

RUN mkdir -p /home/coder/project \
    && chown -R coder:coder /home/coder/project

WORKDIR /home/coder/project

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:10000", "--auth", "password", "--trusted-origins", "*.clouddabba.dev", "--trusted-origins", "clouddabba.dev", "--log", "debug", "/home/coder/project"]
