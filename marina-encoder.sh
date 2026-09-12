#!/bin/bash
cd /home/hernandezdiazjm00/marina-gaming-tv

FORMATO="best[ext=mp4][height<=360]"
CLIENTES=("android" "ios" "web" "mweb")

readarray -t VIDEOS_PROG < programacion.txt
readarray -t VIDEOS_COM < comerciales.txt
readarray -t VIDEOS_CORT < cortinillas.txt

TOT_PROG=${#VIDEOS_PROG[@]}
TOT_COM=${#VIDEOS_COM[@]}
TOT_CORT=${#VIDEOS_CORT[@]}

IDX_PROG=0
IDX_COM=0
IDX_CORT=0
ESTADO=0 

# USA LA RUTA REAL QUE DEVUELVA 'which yt-dlp'
YTDLP_PATH="/usr/local/bin/yt-dlp"

descargar_hidra() {
    local url_video=$1
    local archivo_salida=$2
    local exito=0

    for cliente in "${CLIENTES[@]}"; do
        if nice -n 19 "$YTDLP_PATH" --limit-rate 1.5M -f "$FORMATO" -o "$archivo_salida" \
           --extractor-args "youtube:player_client=$cliente" --socket-timeout 15 \
           --no-warnings "$url_video"; then
            exito=1
            break
        fi
    done

    if [ $exito -eq 0 ]; then
        echo "   [ALERTA] YouTube bloqueó. Generando Bumper de emergencia..."
        ffmpeg -f lavfi -i color=c=black:s=640x360:r=24 -f lavfi -i anullsrc=r=48000:cl=stereo -c:v libx264 -c:a aac -t 5 -y "$archivo_salida" > /dev/null 2>&1
    fi
}

echo "📺 [DIRECTOR] Arrancando transmisión limpia..."
descargar_hidra "${VIDEOS_CORT[0]}" "actual.mp4"
IDX_CORT=$(( (IDX_CORT + 1) % TOT_CORT ))

rm -f *.ts index.m3u8 index.m3u8.tmp

while true; do
    ESTADO_SIGUIENTE=$(( (ESTADO + 1) % 3 ))
    URL_SIGUIENTE=""

    if [ $ESTADO_SIGUIENTE -eq 0 ]; then
        URL_SIGUIENTE="${VIDEOS_CORT[$IDX_CORT]}"
        IDX_CORT=$(( (IDX_CORT + 1) % TOT_CORT ))
        echo "📥 [DIRECTOR JIT] Siguiente: CORTINILLA"
    elif [ $ESTADO_SIGUIENTE -eq 1 ]; then
        URL_SIGUIENTE="${VIDEOS_PROG[$IDX_PROG]}"
        IDX_PROG=$(( (IDX_PROG + 1) % TOT_PROG ))
        echo "📥 [DIRECTOR JIT] Siguiente: PROGRAMA PRINCIPAL"
    elif [ $ESTADO_SIGUIENTE -eq 2 ]; then
        URL_SIGUIENTE="${VIDEOS_COM[$IDX_COM]}"
        IDX_COM=$(( (IDX_COM + 1) % TOT_COM ))
        echo "📥 [DIRECTOR JIT] Siguiente: COMERCIAL"
    fi

    # Descargar en segundo plano sin alterar el procesador
    descargar_hidra "$URL_SIGUIENTE" "siguiente.mp4" &
    PID_DESCARGA=$!

    echo "📡 [DIRECTOR] Emitiendo señal estable (speed 1.0x)..."
    nice -n 19 timeout 12h ffmpeg -re -i actual.mp4 -c copy -fflags +genpts -hls_time 10 -hls_list_size 6 -hls_flags delete_segments+append_list+omit_endlist index.m3u8
    
    timeout 5m wait $PID_DESCARGA 2>/dev/null

    echo "🗑️ [DIRECTOR] Rotando cinta..."
    rm -f actual.mp4
    if [ -f "siguiente.mp4" ]; then
        mv siguiente.mp4 actual.mp4
    else
        ffmpeg -f lavfi -i color=c=black:s=640x360:r=24 -f lavfi -i anullsrc=r=48000:cl=stereo -c:v libx264 -c:a aac -t 5 -y actual.mp4 > /dev/null 2>&1
    fi

    ESTADO=$ESTADO_SIGUIENTE
done