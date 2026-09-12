#!/bin/bash
cd /home/hernandezdiazjm00/marina-gaming-tv

FORMATO="best[ext=mp4][height<=360]"
CLIENTES=("android" "ios" "web" "mweb")
YTDLP_PATH="/usr/local/bin/yt-dlp"

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

descargar_video() {
    local url_video=$1
    local archivo_salida=$2
    local exito=0

    echo "📥 [DIRECTOR] Descargando contenido..."
    for cliente in "${CLIENTES[@]}"; do
        if nice -n 19 "$YTDLP_PATH" --limit-rate 1.0M -f "$FORMATO" -o "$archivo_salida" \
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

echo "📺 [DIRECTOR] Arrancando transmisión secuencial..."
rm -f *.ts index.m3u8 index.m3u8.tmp actual.mp4

while true; do
    URL_ACTUAL=""
    if [ $ESTADO -eq 0 ]; then
        URL_ACTUAL="${VIDEOS_CORT[$IDX_CORT]}"
        IDX_CORT=$(( (IDX_CORT + 1) % TOT_CORT ))
        echo "📺 [DIRECTOR] Turno de: CORTINILLA"
    elif [ $ESTADO -eq 1 ]; then
        URL_ACTUAL="${VIDEOS_PROG[$IDX_PROG]}"
        IDX_PROG=$(( (IDX_PROG + 1) % TOT_PROG ))
        echo "📺 [DIRECTOR] Turno de: PROGRAMA PRINCIPAL"
    elif [ $ESTADO -eq 2 ]; then
        URL_ACTUAL="${VIDEOS_COM[$IDX_COM]}"
        IDX_COM=$(( (IDX_COM + 1) % TOT_COM ))
        echo "📺 [DIRECTOR] Turno de: COMERCIAL"
    fi

    # 1. DESCARGA PURA (FFmpeg no corre, CPU libre)
    descargar_video "$URL_ACTUAL" "actual.mp4"

    # 2. EMISIÓN PURA (yt-dlp no corre, FFmpeg corre solo y fluido a 1.0x)
    echo "📡 [DIRECTOR] Emitiendo al aire..."
    nice -n 19 ffmpeg -re -i actual.mp4 -c copy -fflags +genpts -hls_time 10 -hls_list_size 6 -hls_flags delete_segments+append_list+omit_endlist index.m3u8

    # 3. LIMPIEZA
    rm -f actual.mp4

    # Avanzar ruleta de estados (0 -> 1 -> 2 -> 0)
    ESTADO=$(( (ESTADO + 1) % 3 ))
done