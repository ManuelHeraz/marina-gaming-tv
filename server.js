// server.js

const { addonBuilder, serveHTTP } = require("stremio-addon-sdk");
const manifest = require("./manifest"); 
const { VOD_CATALOG, LIVE_CATALOG } = require("./catalog"); 

const builder = new addonBuilder(manifest);

// --- 1. MANEJADOR DE CATÁLOGOS ---
builder.defineCatalogHandler(({ type, id }) => {
    if (type === "tv" && id === "marina_channels") {
        const liveMetas = LIVE_CATALOG.map(canal => ({
            id: canal.id, type: canal.type, name: canal.name,
            poster: canal.poster, description: canal.description
        }));
        return Promise.resolve({ metas: liveMetas });
    }

    if (type === "movie" && id === "marina_vod") {
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
    // Unimos ambos catálogos temporalmente para buscar el ID solicitado
    const allContent = [...VOD_CATALOG, ...LIVE_CATALOG];
    const item = allContent.find(v => v.id === id);
    
    if (item) {
        return Promise.resolve({
            meta: {
                id: item.id, type: item.type, name: item.name,
                poster: item.poster, description: item.description
            }
        });
    }

    return Promise.resolve({ meta: {} });
});

// --- 3. MANEJADOR DE STREAM ---
builder.defineStreamHandler(({ type, id }) => {
    if (type === "tv") {
        const canal = LIVE_CATALOG.find(c => c.id === id);
        if (canal) {
            return Promise.resolve({ streams: [{ title: "Transmisión en Vivo", url: canal.url }] });
        }
    }

    if (type === "movie") {
        const video = VOD_CATALOG.find(v => v.id === id);
        if (video) {
            return Promise.resolve({ streams: [{ title: "Ver en Stremio (YouTube)", ytId: video.ytId }] });
        }
    }

    return Promise.resolve({ streams: [] });
});

//serveHTTP(builder.getInterface(), { port: 7000 });
serveHTTP(builder.getInterface(), { port: process.env.PORT || 7000, host: '0.0.0.0' });
console.log("Motor de Marina Gaming ejecutándose con código modularizado...");