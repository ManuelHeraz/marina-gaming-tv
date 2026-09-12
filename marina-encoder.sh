#!/bin/bash
cd /home/hernandezdiazjm00/marina-gaming-tv

# Formato estricto para MP4 a 360p (ultra ligero)
FORMATO="best[ext=mp4][height<=360]"

# Leemos la lista de programación
readarray -t VIDEOS < programacion.txt
TOTAL_VIDEOS=${#VIDEOS[@]}

echo "📺 [DIRECTOR] Preparando el programa de inicio..."
yt-dlp -f "$FORMATO" -o "actual.mp4" "${VIDEOS[0]}"

# Limpiamos basura de transmisiones pasadas
rm -f *.ts index.m3u8 index.m3u8.tmp

i=0
# BUCLE INFINITO DE TELEVISIÓN
while true; do
    # Calculamos el índice del siguiente video. Si llega al final, vuelve al 0 matemáticamente.
    SIGUIENTE_IDX=$(( (i + 1) % TOTAL_VIDEOS ))
    
    echo "📥 [DIRECTOR] Descargando programa secundario en las sombras..."
    yt-dlp -f "$FORMATO" -o "siguiente.mp4" "${VIDEOS[$SIGUIENTE_IDX]}" &
    PID_DESCARGA=$!
    
    echo "📡 [DIRECTOR] Emitiendo programa actual..."
    ffmpeg -re -i actual.mp4 -c copy -fflags +genpts -hls_time 10 -hls_list_size 6 -hls_flags delete_segments+append_list index.m3u8
    
    # Esperamos a que la descarga del siguiente video haya terminado
    wait $PID_DESCARGA 2>/dev/null
    
    echo "🗑️ [DIRECTOR] Relevo JIT: Destruyendo archivo viejo y rotando..."
    rm actual.mp4
    if [ -f "siguiente.mp4" ]; then
        mv siguiente.mp4 actual.mp4
    fi
    
    # Avanzamos al siguiente programa
    i=$SIGUIENTE_IDX
done