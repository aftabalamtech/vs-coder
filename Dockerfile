FROM codercom/code-server:latest

EXPOSE 8080

WORKDIR /home/coder/project

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "/home/coder/project"]
