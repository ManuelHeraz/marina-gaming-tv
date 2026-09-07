// manifest.js

const manifest = {
    id: "org.marinagaming.tv",
    version: "1.2.0", // Subimos versión por la refactorización
    name: "Marina Gaming TV",
    description: "Transmisiones exclusivas y contenido VOD de la comunidad.",
    logo: "https://lh3.googleusercontent.com/rd-d/ALs6j_FyFUVfGzHXQyT_uAXZxQzUmTbN1r7zqBoSB54yOwD0HQ1lUH0tJEcjqmjEPDgcpdM6MKyjz6lXX81p6FX-4nJBLzDPhEU1HouMIhnmhACT3Mv0fndJf-t19TBiGYqy3EE5pMun18-rCfMeYwFb1tjP-tx-nXoxBw2TPLin5Dlf4Pf2zVseQ5Hb-QjwlVB3r_j9QBYMIaG_7uk9W1ykulzwXOgiHd4TkpfFGN9DrfLxvGQFiDVLoYr3x1b36829fsJDMSUl4djPzN9FJuirCSW6lZ_EUF8CX9VrY5Q2VS2F8r2AvyinFJnT9yJfDVJv8iVByCFQF7eOYf5yozYeYz0HUoiG_YYwGf5kk-RNlu63QJ9Zgez2HF9Ba2I7rrQ5nH2cF3mwPcwDWp8WavOLZYRT6e_hcrf8sRlEx_p_qPvArU6uVN_EBZ1q5Ge1LE9JkMOmyGyqLHpEMdIvjfWYN2kvKJl1hsnmXQZhfV0gjQw3BzNIDd6h4MaGurS1v_Ry6RSTN4I8mSA03HqpUcY-2DqcDxdPKmqJ6T7reJ7Zf-FEzAJ3CkSqIoQyD1Lmi7CRJAw9FmEGWr3RcuFCa1-GBEhHWWGd_sTrKqbgXcaqYyik5rUR48FSSjUXXJBTZxOqErofFoXdMvP3m_Aj-ENOiUmkXntS0FrInszD9zYIAAXvH0R9DYHwFlQDlDzgP2AcD6bFCMuSFCaqcmIKbYn_fCrW4oA53LomQ8DnNukZvkkjpFbyPPNgtR4G986UqQhXWm_wrsjXuMrfurm3Z-MSkQtKvyDpATSrJ2HILcpdc20FG0vFcCE-psBjdcWctIeumV0ykhKSftlfku9-pqrAEx_pmCj_6gbes_vGqoDoj4qLhxltUfMbLQhEg1n8m3L-GWzy3OrskKQhzkJXFyK73uyO0e5SO3nW-4CpizqLTfk0UzkKQMZrrS1MTJbqDvZN2cdpeA4355dlfqD_dk6sb5mpW9D-I0c1ZViq3jsltY38Gzw9VZDRkjpYSeY_tH7LasfSM56zJfUfVEMlA7aRO8of_qHph7kuYQIFHMPnFsa2Rglbvs1vORQRbxrfygfGlJYTR-IDVAu2dbEaeazzk1W7dr-hGllWquAMilO8cg4VQLnD-ALudi2CGFMK_UgKq5htLQFx8MPNHV0hFZN9W3oxhHlUYIotzp7rQMyp6ovnD9CtT31TZTLakf0JxmrhTQH_j56i4xbpZIX_5qnkrybB8QW9eqmumlgQMaJcK6pT3Fc_O_MoOKQ7QORoLoLElcnNqtmye6uydeD48Q=w2000-h1944",
    resources: ["catalog", "meta", "stream"],
    types: ["tv", "movie"],
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