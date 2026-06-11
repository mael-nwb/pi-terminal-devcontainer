FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git bash xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Copie de la Feature locale et exécution de l'installateur.
COPY src/pi-cli /tmp/feature
RUN sh /tmp/feature/install.sh \
    && rm -rf /tmp/feature

# Vérification rapide
RUN sh -lc "command -v pi >/dev/null 2>&1 || (echo 'pi introuvable' && exit 1)"

CMD ["bash"]
