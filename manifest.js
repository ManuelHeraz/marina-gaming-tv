const manifest = {
    id: "org.marinagaming.tv",
    version: "1.3.0", // Subimos versión para forzar a Stremio a refrescar
    name: "Marina Gaming TV",
    description: "Transmisiones exclusivas y contenido VOD de la comunidad.",
    resources: ["catalog", "meta", "stream"],
    types: ["movie", "series", "tv"], // Ampliamos los tipos soportados
    catalogs: [
        {
            type: "tv",
            id: "marina_channels",
            name: "Marina Gaming En Vivo"
        },
        {
            type: "movie",
            id: "marina_vod",
            name: "Marina Gaming On Demand"
        }
    ],
    idPrefixes: ["marina_"]
};

module.exports = manifest;