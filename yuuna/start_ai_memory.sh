#!/bin/bash

# Inicia o servidor ai-memory (HTTP + Web UI)
# Binário: %LOCALAPPDATA%/ai-memory/ai-memory.exe
# Data dir: ~/.local/share/ai-memory

AI_MEMORY_BIN="$LOCALAPPDATA/ai-memory/ai-memory.exe"
AI_MEMORY_DATA="$HOME/.local/share/ai-memory"

if [ ! -f "$AI_MEMORY_BIN" ]; then
    echo "❌ ai-memory.exe não encontrado em $AI_MEMORY_BIN"
    exit 1
fi

echo "🚀 Iniciando ai-memory em background..."
echo "   HTTP:  http://127.0.0.1:49374"
echo "   Web UI incluído"
echo "   Pode fechar o terminal."

nohup "$AI_MEMORY_BIN" \
    --data-dir "$AI_MEMORY_DATA" \
    serve \
    --transport http \
    --enable-web \
    > /dev/null 2>&1 &

echo "   PID: $!"
