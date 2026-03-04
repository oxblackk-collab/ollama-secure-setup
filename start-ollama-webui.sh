#!/bin/zsh
# Script para iniciar Ollama + Open WebUI
# Uso: ~/start-ollama-webui.sh

echo "=== Iniciando Ollama ==="
if curl -s http://127.0.0.1:11434 > /dev/null 2>&1; then
    echo "✅ Ollama ya está corriendo"
else
    OLLAMA_HOST="127.0.0.1:11434" /Applications/Ollama.app/Contents/Resources/ollama serve &>/tmp/ollama.log &
    sleep 3
    echo "✅ Ollama iniciado"
fi

echo "\n=== Iniciando Open WebUI ==="
pkill -f "open-webui serve" 2>/dev/null; sleep 1

OLLAMA_BASE_URL=http://127.0.0.1:11434 \
WEBUI_AUTH=true \
ENABLE_SIGNUP=false \
DEFAULT_USER_ROLE=user \
/Users/guidoperassolopuhl/anaconda3/envs/openwebui/bin/open-webui serve --host 127.0.0.1 --port 3000 &>/tmp/openwebui.log &

sleep 12
echo "✅ Open WebUI corriendo en http://127.0.0.1:3000"
open http://127.0.0.1:3000
