FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema: FFmpeg, Python, Curl y AWS CLI
RUN apt-get update && apt-get install -y \
    ffmpeg \
    python3 \
    curl \
    unzip \
    awscli \
    && rm -rf /var/lib/apt/lists/*

# Instalar la última versión de yt-dlp de forma global
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar todo el código del repositorio al contenedor
COPY . /app

# Dar permisos de ejecución a los scripts
RUN chmod +x marina-encoder.sh marina-sync.sh entrypoint.sh

# Comando de arranque que lanzará ambos motores
CMD ["./entrypoint.sh"]