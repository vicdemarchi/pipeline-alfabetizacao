CREATE TABLE IF NOT EXISTS
  `tech-alfabetizacao-vdemarchi.bronze.eventos_streaming`
(
  event_id STRING,
  id_municipio STRING,
  ano INT64,
  taxa_alfabetizacao FLOAT64,
  tipo_evento STRING,
  data_evento TIMESTAMP,
  data_ingestao TIMESTAMP,
  dado_simulado BOOL,
  origem STRING
)
PARTITION BY DATE(data_ingestao)
CLUSTER BY id_municipio, tipo_evento;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.silver.eventos_streaming`
PARTITION BY DATE(data_ingestao)
CLUSTER BY id_municipio, tipo_evento
AS
SELECT
  event_id,
  NULLIF(TRIM(id_municipio), '') AS id_municipio,
  ano,
  taxa_alfabetizacao,
  UPPER(NULLIF(TRIM(tipo_evento), '')) AS tipo_evento,
  data_evento,
  data_ingestao,
  dado_simulado,
  NULLIF(TRIM(origem), '') AS origem,
  (
    event_id IS NOT NULL
    AND NULLIF(TRIM(id_municipio), '') IS NOT NULL
    AND ano BETWEEN 2023 AND 2030
    AND taxa_alfabetizacao BETWEEN 0 AND 100
    AND data_evento IS NOT NULL
    AND data_ingestao IS NOT NULL
    AND dado_simulado IS TRUE
  ) AS registro_valido
FROM `tech-alfabetizacao-vdemarchi.bronze.eventos_streaming`
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY event_id
  ORDER BY data_ingestao DESC
) = 1;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.gold.indicador_streaming`
AS
WITH ultimos_eventos AS (
  SELECT
    event_id,
    id_municipio,
    ano,
    taxa_alfabetizacao,
    tipo_evento,
    data_evento,
    data_ingestao,
    dado_simulado,
    origem,
    TIMESTAMP_DIFF(data_ingestao, data_evento, SECOND) AS latencia_segundos
  FROM `tech-alfabetizacao-vdemarchi.silver.eventos_streaming`
  WHERE registro_valido
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_municipio
    ORDER BY data_evento DESC, data_ingestao DESC, event_id DESC
  ) = 1
)
SELECT *, CURRENT_TIMESTAMP() AS data_processamento
FROM ultimos_eventos;
