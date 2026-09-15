FROM codercom/code-server:latest

USER root

COPY start.sh /usr/local/bin/start-code-server.sh
RUN chmod +x /usr/local/bin/start-code-server.sh \
    && mkdir -p /home/coder/project \
    && chown -R coder:coder /home/coder/project

USER coder

WORKDIR /home/coder/project

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start-code-server.sh"]
