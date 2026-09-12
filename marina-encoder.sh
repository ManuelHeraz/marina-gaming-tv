#!/bin/bash
cd /app

FORMATO="best[ext=mp4][height<=360]"
CLIENTES=("android" "ios" "web" "mweb")
YTDLP_PATH="/usr/local/bin/yt-dlp"

readarray -t VIDEOS_PROG < programacion.txt
readarray -t VIDEOS_COM < comerciales.txt
readarray -t VIDEOS_CORT < cortinillas.txt

TOT_PROG=${#VIDEOS_PROG[@]}
TOT_COM=${#VIDEOS_COM[@]}
TOT_CORT=${#VIDEOS_CORT[@]}

mkdir -p cola_videos
rm -f cola_videos/*.mp4 *.ts index.m3u8 index.m3u8.tmp actual.mp4 emergencia.mp4

# ==========================================
# 1. MOTOR DE DESCARGA: PATRÓN DE TV REAL
# ==========================================
motor_descarga() {
    local ESTADO_DL=0
    local CONTADOR=0

    while true; do
        NUM_VIDEOS=$(ls -1 cola_videos/*.mp4 2>/dev/null | wc -l)

        if [ "$NUM_VIDEOS" -lt 3 ]; then
            local URL_DL=""
            
            case $ESTADO_DL in
                0) URL_DL="${VIDEOS_PROG[$(( RANDOM % TOT_PROG ))]}" ;;
                1) URL_DL="${VIDEOS_CORT[$(( RANDOM % TOT_CORT ))]}" ;;
                2) URL_DL="${VIDEOS_COM[$(( RANDOM % TOT_COM ))]}" ;;
                3) URL_DL="${VIDEOS_COM[$(( RANDOM % TOT_COM ))]}" ;;
                4) URL_DL="${VIDEOS_CORT[$(( RANDOM % TOT_CORT ))]}" ;;
            esac

            ARCHIVO_TMP="temp_$CONTADOR.mp4"
            ARCHIVO_FINAL=$(printf "cola_videos/%06d.mp4" $CONTADOR)

            local exito=0
            for cliente in "${CLIENTES[@]}"; do
                if nice -n 19 "$YTDLP_PATH" --limit-rate 1.5M -f "$FORMATO" -o "$ARCHIVO_TMP" \
                   --extractor-args "youtube:player_client=$cliente" --socket-timeout 15 \
                   --no-warnings "$URL_DL" > /dev/null 2>&1; then
                    exito=1
                    break
                fi
            done

            if [ $exito -eq 1 ]; then
                mv "$ARCHIVO_TMP" "$ARCHIVO_FINAL"
            else
                if [ -f "fallback.mp4" ]; then
                    cp fallback.mp4 "$ARCHIVO_FINAL"
                else
                    ffmpeg -f lavfi -i color=c=222222:s=640x360:r=24 -f lavfi -i anullsrc=r=48000:cl=stereo -c:v libx264 -c:a aac -t 15 -y "$ARCHIVO_FINAL" > /dev/null 2>&1
                fi
            fi

            ESTADO_DL=$(( (ESTADO_DL + 1) % 5 ))
            CONTADOR=$(( CONTADOR + 1 ))
        else
            sleep 5
        fi
    done
}

motor_descarga &
echo "📺 [DIRECTOR] Arrancando Sistema Anti-Glitches con Buffer Extendido..."
sleep 15

# ==========================================
# 2. MOTOR DE TRANSMISIÓN (AL AIRE)
# ==========================================
# Variables maestras de estabilidad (Colchón de 10 minutos y anti-colisiones)
HLS_FLAGS="-hls_time 10 -hls_list_size 60 -hls_flags delete_segments+append_list+omit_endlist+temp_file -hls_segment_filename segment_%Y%m%d%H%M%S.ts -strftime 1"
while true; do
    VIDEO_ACTUAL=$(ls -1 cola_videos/*.mp4 2>/dev/null | head -n 1)

    if [ -n "$VIDEO_ACTUAL" ]; then
        echo "📡 [DIRECTOR] Emitiendo al aire: $VIDEO_ACTUAL"
        nice -n 19 ffmpeg -re -i "$VIDEO_ACTUAL" -c copy -fflags +genpts $HLS_FLAGS index.m3u8
        rm -f "$VIDEO_ACTUAL"
    else
        echo "⏳ [DIRECTOR] Cola vacía. Usando salvavidas..."
        if [ -f "fallback.mp4" ]; then
            nice -n 19 ffmpeg -re -i fallback.mp4 -c copy -fflags +genpts $HLS_FLAGS index.m3u8
        else
            ffmpeg -f lavfi -i color=c=222222:s=640x360:r=24 -f lavfi -i anullsrc=r=48000:cl=stereo -c:v libx264 -c:a aac -t 5 -y emergencia.mp4 > /dev/null 2>&1
            nice -n 19 ffmpeg -re -i emergencia.mp4 -c copy -fflags +genpts $HLS_FLAGS index.m3u8
        fi
    fi
done