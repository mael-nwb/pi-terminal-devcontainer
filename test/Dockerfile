FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git bash xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Copie de la Feature locale et exécution de l'installateur.
COPY src/pi-cli /tmp/feature
RUN sh /tmp/feature/install.sh \
    && rm -rf /tmp/feature

# Vérifications rapides
RUN sh -lc "command -v pi >/dev/null 2>&1 || (echo 'pi introuvable' && exit 1)"
RUN sh -lc "test ! -L /usr/local/bin/pi"
RUN sh -lc "test -x /usr/local/lib/pi-cli/init-agent-config.sh"
RUN bash -lc 'test "$PI_CODING_AGENT_DIR" = "/root/.pi-devcontainer/agent"'
RUN mkdir -p /root/.pi/agent \
    && cat > /root/.pi/agent/models.json <<'EOF'
{
  "providers": {
    "ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "models": [
        { "id": "llama3.1:8b" }
      ]
    }
  }
}
EOF
RUN cat > /root/.pi/agent/settings.json <<'EOF'
{
  "enabledModels": ["ollama/*"],
  "theme": "dark"
}
EOF
RUN sh -lc "pi --version >/dev/null 2>&1"
RUN grep -q 'http://host.docker.internal:11434/v1' /root/.pi-devcontainer/agent/models.json
RUN sh -lc "! grep -q 'enabledModels' /root/.pi-devcontainer/agent/settings.json"

CMD ["bash"]
