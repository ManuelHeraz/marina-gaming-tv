#!/bin/bash
cd /app

echo "🚀 [FLY.IO] Iniciando Sincronizador de Red en segundo plano..."
./marina-sync.sh &

echo "📺 [FLY.IO] Arrancando el Director de Encoder..."
./marina-encoder.sh