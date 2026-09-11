// catalog.js

const VOD_CATALOG = [
    {
        id: "marina_vod_01_v2",
        type: "movie",
        name: "Golpe de Estado: Traición a la Patria",
        poster: "https://manuelheraz.github.io/MarinaGaming/pages/martv/img/m1.jpg", 
        description: "La lealtad tiene un límite. Cuando el sistema está podrido desde la raíz, ¿hasta dónde llegarías para limpiarlo?Bienvenidos al largometraje definitivo de la Marina Gaming. Tras un devastador ataque cibernético a los servidores de PEMEX, el Secretario de Marina, Gabriel Navarro, es empujado a un tablero de ajedrez geopolítico donde nadie juega limpio. Lo que comienza como una operación encubierta de las Fuerzas Especiales (F.E.S.) para limpiar la imagen de la institución, rápidamente desciende en una espiral de operaciones black ops, infiltraciones a portaaviones estadounidenses, chantajes internacionales y una guerra civil en las calles.SEDENA contra MARINA. El Presidente contra su propio gabinete. Cuando la verdad se quema en los pasillos de la embajada y las emboscadas manchan las carreteras de sangre, solo puede quedar una resistencia. Pónganse cómodos, apaguen las luces y disfruten de esta película militar de 1 hora creada enteramente dentro del motor de Grand Theft Auto V.",
        ytId: "3Yqs_qzRA9c"
    },
    {
        id: "marina_vod_02_v2",
        type: "movie",
        name: "La Batalla de Los Ángeles",
        poster: "https://upload.wikimedia.org/wikipedia/en/a/a5/Grand_Theft_Auto_V.png",
        description: "¿Qué pasaría si Los Ángeles sufriera una invasión militar a gran escala hoy mismo? Presentamos La Batalla de Los Ángeles, un mediometraje cinemático creado enteramente dentro del motor de GTA V, narrando 48 horas de conflicto intenso desde la perspectiva de la infantería, la fuerza aérea y las unidades blindadas.Del 4 al 6 de Mayo, acompañamos a la unidad Cero en el desembarco costero, al escuadrón Tlaloc dominando los cielos con Arbesu, y a la fuerza blindada abriéndose paso a través de la oscuridad del metro de Los Santos. Esta no es una partida normal; es una historia de sacrificio, táctica y caos coordinado por la comunidad de Marina Gaming.",
        ytId: "ZSFQjThMPuo"
    },
    {
        id: "marina_vod_03_v2",
        type: "movie",
        name: "Ruzoone42",
        poster: "https://upload.wikimedia.org/wikipedia/en/e/e0/Assetto_Corsa_cover.jpg",
        description: "Una pareja de mercenarios de muy buen nivel, en algun punto de su vida aceptaron el hecho de que tarde o temprano alguno de los dos iba a caer en una mision, la chica lo mencionó en una de las tantas peticiones a las que ambos asistieron nacimos para morir dijo ella, sin esperar jamas, que ella seria quien caeria en una importante peticion para acabar con un objetivo importante, él decide terminar el trabajo, un trabajo que en pareja ya era imposible, en solitario resulta un suicidio.",
        ytId: "7DDB1vMxoIw"
    }
];

const LIVE_CATALOG = [
    {
        id: "marina_live_01_v2",
        type: "tv",
        name: "Marina Gaming TV 24/7",
        poster: "https://manuelheraz.github.io/MarinaGaming/pages/martv/img/m4.jpg",
        description: "Canal 24/7 sobre Gaming, Videojuegos, un poco de anime y mas",
        url: "https://pub-3404987dd8c841489f9a817427cea40d.r2.dev/tv-envivo/index.m3u8"
    }
];

// Exportamos ambas listas para usarlas en server.js
module.exports = { VOD_CATALOG, LIVE_CATALOG };