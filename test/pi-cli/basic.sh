#!/bin/bash
set -e

# Import test lib
source dev-container-features-test-lib

mkdir -p /root/.pi/agent
cat > /root/.pi/agent/models.json <<'EOF'
{
  "providers": {
    "ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "models": [
        { "id": "llama3.1:8b" }
      ]
    }
  }
}
EOF

cat > /root/.pi/agent/settings.json <<'EOF'
{
  "enabledModels": ["ollama/*"],
  "theme": "dark"
}
EOF

# Tests
check "pi cli installed" command -v pi
check "pi wrapper is not a symlink" test ! -L /usr/local/bin/pi
check "pi init script installed" test -x /usr/local/lib/pi-cli/init-agent-config.sh
check "pi login shell exports isolated agent dir" bash -lc 'test "$PI_CODING_AGENT_DIR" = "/root/.pi-devcontainer/agent"'
check "pi version" pi --version
check "pi container agent dir seeded" test -f /root/.pi-devcontainer/agent/.seeded-from-host
check "pi source config unchanged" grep -q 'http://localhost:11434/v1' /root/.pi/agent/models.json
check "pi container config rewritten" grep -q 'http://host.docker.internal:11434/v1' /root/.pi-devcontainer/agent/models.json
check "pi container settings cleared enabledModels" sh -lc '! grep -q '"'"'enabledModels'"'"' /root/.pi-devcontainer/agent/settings.json'

reportResults
