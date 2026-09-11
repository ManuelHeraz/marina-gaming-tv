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
    const allContent = [...VOD_CATALOG, ...LIVE_CATALOG];
    const item = allContent.find(v => v.id === id);

    if (item) {
        if (item.type === "tv") {
            return Promise.resolve({ 
                streams: [{ 
                    title: "Marina Gaming TV (En Vivo)", 
                    url: item.url,
                    behaviorHints: { 
                        notWebReady: false,
                        bingeGroup: "marina-live"
                    }
                }] 
            });
        }
        if (item.type === "movie") {
            return Promise.resolve({ 
                streams: [{ 
                    title: "Ver en Stremio", 
                    ytId: item.ytId 
                }] 
            });
        }
    }

    return Promise.resolve({ streams: [] });
});

// --- DESPLIEGUE HTTPS NATIVO (Escudo-SSL) ---
const app = express();
app.use(getRouter(builder.getInterface()));

const opcionesSSL = {
    key: fs.readFileSync('/home/hernandezdiazjm00/.acme.sh/marbot.duckdns.org_ecc/marbot.duckdns.org.key'),
    cert: fs.readFileSync('/home/hernandezdiazjm00/.acme.sh/marbot.duckdns.org_ecc/fullchain.cer')
};

https.createServer(opcionesSSL, app).listen(7000, '0.0.0.0', () => {
    console.log("📺 Motor de Marina Gaming TV ejecutándose con HTTPS nativo en el puerto 7000...");
});