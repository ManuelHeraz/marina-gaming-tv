#!/bin/bash
cd /home/hernandezdiazjm00/marina-gaming-tv

while true; do
    aws s3 sync . s3://marina-vod/tv-envivo/ --exclude "*" --include "*.ts" --include "*.m3u8" --endpoint-url https://8d52b72dcf61ba4eaa74e4c4cafe3b43.r2.cloudflarestorage.com --quiet
    sleep 5
done