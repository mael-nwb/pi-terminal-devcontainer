# Pi Terminal Devcontainer

Ce dépôt contient une Feature Dev Container « pi-cli » et ses tests automatisés.

## Utilisation (Feature Dev Container)

Pour utiliser la feature dans un `devcontainer.json`:

```json
"features": {
  "./src/pi-cli": {}
}
```

Depuis GHCR après publication, adaptez le chemin au dépôt publié:

```json
"features": {
  "ghcr.io/mael-nwb/pi-terminal-devcontainer/pi-cli:latest": {}
}
```

La feature n'a pas besoin d'une feature Node préinstallée. Si `node`/`npm` sont absents ou trop anciens, elle installe d'abord Node.js 22 via l'archive officielle, puis lance l'installateur officiel Pi:

```bash
curl -fsSL https://pi.dev/install.sh | sh
```

Dans un Dev Container, la commande `pi` utilise ensuite une copie locale de la configuration dans `~/.pi-devcontainer/agent`. La feature exporte aussi `PI_CODING_AGENT_DIR` vers ce répertoire pour les shells du conteneur. Si une configuration hôte est montée dans `~/.pi/agent`, elle est copiée une seule fois dans ce répertoire interne au conteneur puis isolée. La feature réécrit automatiquement `providers.ollama.baseUrl` de `localhost` vers `host.docker.internal` dans cette copie interne, sans modifier la configuration hôte. Lors de cette copie initiale, `settings.json` est aussi nettoyé de `enabledModels` pour éviter une liste de modèles Ollama obsolète.

## Configuration Pi hôte

Pour réutiliser votre configuration Pi locale, le dossier `${HOME}/.pi` doit exister sur l'hôte avant le rebuild du Dev Container.

Ajoutez ensuite ce mount dans le `devcontainer.json` consommateur, en adaptant le home si votre `remoteUser` n'est pas `vscode`:

```json
"mounts": [
  "source=${localEnv:HOME}/.pi,target=/home/vscode/.pi,type=bind,consistency=cached"
]
```

Si `${HOME}/.pi` est absent, la feature installe uniquement le CLI Pi. Pi devra être configuré après ouverture du conteneur.

La configuration active de Pi dans le conteneur reste `~/.pi-devcontainer/agent`. Le mount hôte sert uniquement de source initiale. Si `/usr/local/bin/pi` est encore un simple symlink ou si `PI_CODING_AGENT_DIR` n'est pas défini dans un shell de login, vous utilisez probablement un artefact GHCR plus ancien et il faut republier / rebuild la feature.

## Tests (Docker)

Construire l'image de test et vérifier que `pi` est présent:

```bash
bash scripts/build_and_test.sh
```

## Structure

- `src/pi-cli/`: Feature locale pour Pi CLI
- `test/pi-cli/`: tests de la feature (scénarios + scripts)
- `test/Dockerfile`: exécute l'installation de la feature sur une image sans Node préinstallé et vérifie la présence de `pi`
- `scripts/build_and_test.sh`: build + run de l'image de test

## Installation via Codex

Collez cette commande dans votre terminal hors du Dev Container. Elle envoie un prompt au CLI Codex pour ajouter la feature Pi à votre projet.

```bash
codex "$(cat <<'EOF'
Ajoute la feature pi-cli à mon Dev Container. Crée ou modifie .devcontainer/devcontainer.json pour inclure:
"features": {
  "ghcr.io/mael-nwb/pi-terminal-devcontainer/pi-cli:latest": {}
}
Si ${HOME}/.pi existe sur l'hôte, ajoute aussi le mount:
"source=${localEnv:HOME}/.pi,target=/home/vscode/.pi,type=bind,consistency=cached"
EOF
)"
```
