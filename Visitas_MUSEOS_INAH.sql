-- =============================================================
-- 1. TABLA RAW CON DATOS MENSUALES POR MUSEO
-- =============================================================

CREATE TABLE visitantes_museos_inah_raw (
    _id INTEGER,
    anio INTEGER,
    estado VARCHAR,
    clave_siinah INTEGER,
    recinto VARCHAR,

    enero_nac INTEGER,
    enero_ext INTEGER,
    febrero_nac INTEGER,
    febrero_ext INTEGER,
    marzo_nac INTEGER,
    marzo_ext INTEGER,
    abril_nac INTEGER,
    abril_ext INTEGER,
    mayo_nac INTEGER,
    mayo_ext INTEGER,
    junio_nac INTEGER,
    junio_ext INTEGER,
    julio_nac INTEGER,
    julio_ext INTEGER,
    agosto_nac INTEGER,
    agosto_ext INTEGER,
    septiembre_nac INTEGER,
    septiembre_ext INTEGER,
    octubre_nac INTEGER,
    octubre_ext INTEGER,
    noviembre_nac INTEGER,
    noviembre_ext INTEGER,
    diciembre_nac INTEGER,
    diciembre_ext INTEGER
);
-- =============================================================
-- 2. TABLA: VISITAS POR ESTADO Y POR AÑO
-- =============================================================

CREATE TABLE visitas_estado_anio AS
SELECT
    anio,
    estado,
    SUM(
        enero_nac + enero_ext +
        febrero_nac + febrero_ext +
        marzo_nac + marzo_ext +
        abril_nac + abril_ext +
        mayo_nac + mayo_ext +
        junio_nac + junio_ext +
        julio_nac + julio_ext +
        agosto_nac + agosto_ext +
        septiembre_nac + septiembre_ext +
        octubre_nac + octubre_ext +
        noviembre_nac + noviembre_ext +
        diciembre_nac + diciembre_ext
    ) AS visitas_totales,
    
    SUM(
        enero_nac + febrero_nac + marzo_nac + abril_nac + mayo_nac + junio_nac +
        julio_nac + agosto_nac + septiembre_nac + octubre_nac + noviembre_nac + diciembre_nac
    ) AS visitas_nacionales,

    SUM(
        enero_ext + febrero_ext + marzo_ext + abril_ext + mayo_ext + junio_ext +
        julio_ext + agosto_ext + septiembre_ext + octubre_ext + noviembre_ext + diciembre_ext
    ) AS visitas_extranjeras

FROM visitantes_museos_inah_raw
GROUP BY anio, estado
ORDER BY anio, estado;
-- =============================================================
-- 3. TABLA DE RANKING POR ESTADO Y AÑO (1 = MENOS VISITADO)
-- =============================================================

CREATE TABLE ranking_estados AS
SELECT
    anio,
    estado,
    visitas_totales,
    RANK() OVER (PARTITION BY anio ORDER BY visitas_totales ASC) AS ranking
FROM visitas_estado_anio
ORDER BY anio, ranking;
-- =============================================================
-- 4. TABLA: VISITAS TOTALES POR MES Y AÑO (NIVEL NACIONAL)
-- =============================================================

DROP TABLE IF EXISTS visitas_por_mes;

CREATE TABLE visitas_por_mes AS
(
    SELECT anio, 'enero' AS mes, SUM(enero_nac + enero_ext) AS visitas
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'febrero', SUM(febrero_nac + febrero_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'marzo', SUM(marzo_nac + marzo_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'abril', SUM(abril_nac + abril_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'mayo', SUM(mayo_nac + mayo_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'junio', SUM(junio_nac + junio_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'julio', SUM(julio_nac + julio_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'agosto', SUM(agosto_nac + agosto_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'septiembre', SUM(septiembre_nac + septiembre_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'octubre', SUM(octubre_nac + octubre_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'noviembre', SUM(noviembre_nac + noviembre_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
)
UNION ALL
(
    SELECT anio, 'diciembre', SUM(diciembre_nac + diciembre_ext)
    FROM visitantes_museos_inah_raw GROUP BY anio
);
-- =============================================================
-- KPI: MES MENOS VISITADO POR AÑO
-- =============================================================

SELECT DISTINCT ON (anio)
    anio,
    mes,
    visitas
FROM visitas_por_mes
ORDER BY anio, visitas ASC;
-- =============================================================
-- KPI: MES MÁS VISITADO POR AÑO
-- =============================================================

SELECT DISTINCT ON (anio)
    anio,
    mes,
    visitas
FROM visitas_por_mes
ORDER BY anio, visitas DESC;
-- =============================================================
-- TABLA FINAL PARA POWER BI: MENOS Y MÁS VISITADO POR AÑO
-- =============================================================

WITH menos AS (
    SELECT DISTINCT ON (anio)
        anio,
        mes AS mes_menos,
        visitas AS visitas_menos
    FROM visitas_por_mes
    ORDER BY anio, visitas ASC
),
mas AS (
    SELECT DISTINCT ON (anio)
        anio,
        mes AS mes_mas,
        visitas AS visitas_mas
    FROM visitas_por_mes
    ORDER BY anio, visitas DESC
)
SELECT
    menos.anio,
    mes_menos,
    visitas_menos,
    mes_mas,
    visitas_mas
FROM menos
JOIN mas USING (anio)
ORDER BY anio;
