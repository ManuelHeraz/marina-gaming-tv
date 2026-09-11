const { addonBuilder, getRouter } = require("stremio-addon-sdk");
const express = require("express");
const https = require("https");
const fs = require("fs");
const manifest = require("./manifest"); 
const { VOD_CATALOG, LIVE_CATALOG } = require("./catalog");

const builder = new addonBuilder(manifest);

// --- 1. MANEJADOR DE CATÁLOGOS ---
builder.defineCatalogHandler(({ type, id }) => {
    if (id === "marina_channels") {
        const liveMetas = LIVE_CATALOG.map(canal => ({
            id: canal.id, type: canal.type, name: canal.name,
            poster: canal.poster, description: canal.description
        }));
        return Promise.resolve({ metas: liveMetas });
    }

    if (id === "marina_vod") {
        const vodMetas = VOD_CATALOG.map(video => ({
            id: video.id, type: video.type, name: video.name,
            poster: video.poster, description: video.description
        }));
        return Promise.resolve({ metas: vodMetas });
    }

    return Promise.resolve({ metas: [] });
});

// --- 2. MANEJADOR DE METADATOS ---
builder.defineMetaHandler(({ type, id }) => {
    const allContent = [...VOD_CATALOG, ...LIVE_CATALOG];
    const item = allContent.find(v => v.id === id);
    
    if (item) {
        return Promise.resolve({
            meta: {
                id: item.id, 
                type: item.type, 
                name: item.name,
                poster: item.poster, 
                description: item.description,
                background: item.poster
            }
        });
    }

    return Promise.resolve({ meta: {} });
});

// --- 3. MANEJADOR DE STREAM BLINDADO ---
builder.defineStreamHandler(({ type, id }) => {
    console.log(`🔎 Stremio pide el stream de -> ${id}`);
    const allContent = [...VOD_CATALOG, ...LIVE_CATALOG];
    const item = allContent.find(v => v.id === id);

    if (item) {
        console.log(`✅ Elemento encontrado en base de datos: ${item.name}`);
        let streamObject = { title: "▶️ Reproducir " + item.name };

        // Construimos el objeto limpio, sin campos "undefined"
        if (item.ytId) {
            streamObject.ytId = item.ytId;
            console.log(`🔗 Enviando YouTube ID a Stremio: ${item.ytId}`);
        } else if (item.url) {
            streamObject.url = item.url;
            console.log(`🔗 Enviando URL HLS a Stremio: ${item.url}`);
        }

        // cacheMaxAge: 0 evita que Stremio guarde caché si algo sale mal
        return Promise.resolve({ streams: [streamObject], cacheMaxAge: 0 });
    }

    console.log(`❌ No se encontró el ID en la base de datos.`);
    return Promise.resolve({ streams: [], cacheMaxAge: 0 });
});

// --- DESPLIEGUE HTTPS NATIVO CON CORS Y LOGS VERBOSOS ---
const app = express();

// Middleware de diagnóstico y CORS obligatorio para Stremio
app.use((req, res, next) => {
    console.log(`📥 [STREMIO PETICIÓN] Método: ${req.method} | URL: ${req.url}`);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});

app.use(getRouter(builder.getInterface()));

const opcionesSSL = {
    key: fs.readFileSync('/home/hernandezdiazjm00/.acme.sh/marbot.duckdns.org_ecc/marbot.duckdns.org.key'),
    cert: fs.readFileSync('/home/hernandezdiazjm00/.acme.sh/marbot.duckdns.org_ecc/fullchain.cer')
};

https.createServer(opcionesSSL, app).listen(7000, '0.0.0.0', () => {
    console.log("📺 Motor de Marina Gaming TV ejecutándose con HTTPS nativo y CORS activo en el puerto 7000...");
});