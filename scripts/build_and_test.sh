#!/usr/bin/env bash
set -euo pipefail

# Construire l'image de test basée sur Debian avec la Feature locale
docker build -t pi-feature-test -f test/Dockerfile .

# Exécuter la commande pi pour valider la présence du binaire
docker run --rm pi-feature-test sh -lc "pi --version"

echo "OK: pi est disponible dans l'image de test."
