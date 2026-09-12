#!/bin/bash
cd /home/hernandezdiazjm00/marina-gaming-tv

FORMATO="best[ext=mp4][height<=360]"
CLIENTES=("android" "ios" "web" "mweb")

# --- 1. CARGAR LAS TRES BÓVEDAS ---
readarray -t VIDEOS_PROG < programacion.txt
readarray -t VIDEOS_COM < comerciales.txt
readarray -t VIDEOS_CORT < cortinillas.txt

TOT_PROG=${#VIDEOS_PROG[@]}
TOT_COM=${#VIDEOS_COM[@]}
TOT_CORT=${#VIDEOS_CORT[@]}

IDX_PROG=0
IDX_COM=0
IDX_CORT=0

# ESTADOS DE TELEVISIÓN:
# 0=Cortinilla Inicial | 1=Programa P1 | 2=Cortinilla Corte | 3=Comercial | 4=Cortinilla Regreso | 5=Programa P2
ESTADO=0 

descargar_hidra() {
    local url_video=$1
    local archivo_salida=$2
    local exito=0

    for cliente in "${CLIENTES[@]}"; do
        if nice -n 19 yt-dlp --limit-rate 1.5M -f "$FORMATO" -o "$archivo_salida" \
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

echo "📺 [DIRECTOR] Arrancando transmisión. Preparando Cortinilla inicial..."
descargar_hidra "${VIDEOS_CORT[0]}" "actual.mp4"
IDX_CORT=$(( (IDX_CORT + 1) % TOT_CORT ))

rm -f *.ts index.m3u8 index.m3u8.tmp prog2.mp4

# --- 2. BUCLE MAESTRO DE TELEVISIÓN DE 6 TIEMPOS ---
while true; do
    ESTADO_SIGUIENTE=$(( (ESTADO + 1) % 6 ))
    
    if [ $ESTADO_SIGUIENTE -eq 0 ]; then
        # Viene la Cortinilla Inicial del SIGUIENTE bloque
        URL_SIGUIENTE="${VIDEOS_CORT[$IDX_CORT]}"; IDX_CORT=$(( (IDX_CORT + 1) % TOT_CORT ))
        echo "📥 [DIRECTOR JIT] Siguiente en cola: CORTINILLA INICIO"
        descargar_hidra "$URL_SIGUIENTE" "siguiente.mp4" &
        PID_DESCARGA=$!

    elif [ $ESTADO_SIGUIENTE -eq 1 ]; then
        # Viene el Programa. Lo descargamos y lo partimos a la mitad JIT.
        URL_SIGUIENTE="${VIDEOS_PROG[$IDX_PROG]}"; IDX_PROG=$(( (IDX_PROG + 1) % TOT_PROG ))
        echo "📥 [DIRECTOR JIT] Siguiente en cola: PROGRAMA (Descargando y dividiendo...)"
        (
            descargar_hidra "$URL_SIGUIENTE" "master.mp4"
            
            if [ -f "master.mp4" ]; then
                # Calcular la mitad en segundos
                DURACION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 master.mp4)
                DURACION=${DURACION%.*} # Redondear
                MITAD=$(( DURACION / 2 ))
                
                # Partir en dos archivos sin usar CPU (-c copy)
                ffmpeg -y -i master.mp4 -t "$MITAD" -c copy prog1.mp4 > /dev/null 2>&1
                ffmpeg -y -i master.mp4 -ss "$MITAD" -c copy prog2.mp4 > /dev/null 2>&1
                
                rm master.mp4
                mv prog1.mp4 siguiente.mp4
            else
                # Si falló, crear bumpers de emergencia
                ffmpeg -f lavfi -i color=c=black:s=640x360:r=24 -f lavfi -i anullsrc=r=48000:cl=stereo -c:v libx264 -c:a aac -t 5 -y siguiente.mp4 > /dev/null 2>&1
                cp siguiente.mp4 prog2.mp4
            fi
        ) &
        PID_DESCARGA=$!

    elif [ $ESTADO_SIGUIENTE -eq 2 ]; then
        URL_SIGUIENTE="${VIDEOS_CORT[$IDX_CORT]}"; IDX_CORT=$(( (IDX_CORT + 1) % TOT_CORT ))
        echo "📥 [DIRECTOR JIT] Siguiente en cola: CORTINILLA DE CORTE COMERCIAL"
        descargar_hidra "$URL_SIGUIENTE" "siguiente.mp4" &
        PID_DESCARGA=$!

    elif [ $ESTADO_SIGUIENTE -eq 3 ]; then
        URL_SIGUIENTE="${VIDEOS_COM[$IDX_COM]}"; IDX_COM=$(( (IDX_COM + 1) % TOT_COM ))
        echo "📥 [DIRECTOR JIT] Siguiente en cola: COMERCIAL"
        descargar_hidra "$URL_SIGUIENTE" "siguiente.mp4" &
        PID_DESCARGA=$!

    elif [ $ESTADO_SIGUIENTE -eq 4 ]; then
        URL_SIGUIENTE="${VIDEOS_CORT[$IDX_CORT]}"; IDX_CORT=$(( (IDX_CORT + 1) % TOT_CORT ))
        echo "📥 [DIRECTOR JIT] Siguiente en cola: CORTINILLA DE REGRESO"
        descargar_hidra "$URL_SIGUIENTE" "siguiente.mp4" &
        PID_DESCARGA=$!

    elif [ $ESTADO_SIGUIENTE -eq 5 ]; then
        echo "📥 [DIRECTOR JIT] Siguiente en cola: PROGRAMA PARTE 2 (Recuperando caché)"
        # La Parte 2 ya está lista desde el paso 1, solo la movemos.
        (
            mv prog2.mp4 siguiente.mp4
        ) &
        PID_DESCARGA=$!
    fi

    echo "📡 [DIRECTOR] Emitiendo señal actual..."
    nice -n 19 timeout 12h ffmpeg -re -i actual.mp4 -c copy -fflags +genpts -hls_time 10 -hls_list_size 6 -hls_flags delete_segments+append_list index.m3u8
    
    timeout 5m wait $PID_DESCARGA 2>/dev/null

    echo "🗑️ [DIRECTOR] Relevo de cinta completado..."
    rm -f actual.mp4
    if [ -f "siguiente.mp4" ]; then
        mv siguiente.mp4 actual.mp4
    else
        # Bumper extremo si algo falló gravemente en el traspaso
        ffmpeg -f lavfi -i color=c=black:s=640x360:r=24 -f lavfi -i anullsrc=r=48000:cl=stereo -c:v libx264 -c:a aac -t 5 -y actual.mp4 > /dev/null 2>&1
    fi

    # Avanzar el estado
    ESTADO=$ESTADO_SIGUIENTE
done