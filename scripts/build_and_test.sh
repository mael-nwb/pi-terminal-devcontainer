#!/usr/bin/env bash
set -euo pipefail

# Construire l'image de test basée sur Debian avec la Feature locale
docker build -t pi-feature-test -f test/Dockerfile .

# Exécuter quelques checks runtime de base
docker run --rm pi-feature-test sh -lc "pi --version >/dev/null && test ! -L /usr/local/bin/pi"
docker run --rm pi-feature-test bash -lc 'test "$PI_CODING_AGENT_DIR" = "/root/.pi-devcontainer/agent"'

echo "OK: pi est disponible et le mode .pi-devcontainer est actif dans l'image de test."
