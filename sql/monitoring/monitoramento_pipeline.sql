CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.quality.monitoramento_pipeline`
AS
WITH
bronze_batch AS (
  SELECT (
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.bronze.alunos`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_brasil`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_municipio`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_uf`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.bronze.municipio`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.bronze.uf`)
  ) AS volume
),
silver_batch AS (
  SELECT (
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.silver.alunos`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_brasil`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_municipio`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_uf`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.silver.municipio`) +
    (SELECT COUNT(*) FROM `tech-alfabetizacao-vdemarchi.silver.uf`)
  ) AS volume
),
metricas AS (
  SELECT
    'BATCH_BRONZE_SILVER' AS componente,
    s.volume AS volume_processado,
    ABS(b.volume - s.volume) AS registros_com_erro,
    CAST(NULL AS FLOAT64) AS latencia_media_segundos,
    CAST(NULL AS INT64) AS latencia_maxima_segundos,
    CASE WHEN b.volume = s.volume THEN 'APROVADO' ELSE 'ALERTA' END AS status,
    CONCAT('Bronze: ', CAST(b.volume AS STRING), ' | Silver: ', CAST(s.volume AS STRING)) AS detalhe
  FROM bronze_batch b CROSS JOIN silver_batch s

  UNION ALL

  SELECT
    'QUALIDADE_FINAL',
    COUNT(*),
    COUNTIF(status = 'REVISAR'),
    NULL,
    NULL,
    CASE WHEN COUNTIF(status = 'REVISAR') = 0 THEN 'APROVADO' ELSE 'ALERTA' END,
    CONCAT('Regras analisadas: ', CAST(COUNT(*) AS STRING))
  FROM `tech-alfabetizacao-vdemarchi.quality.resumo_validacao_final`

  UNION ALL

  SELECT
    'GOLD_EVOLUCAO',
    COUNT(*),
    COUNT(*) - COUNT(DISTINCT CONCAT(nivel_geografico, '|', codigo_geografico, '|', CAST(ano AS STRING))),
    NULL,
    NULL,
    CASE
      WHEN COUNT(*) = COUNT(DISTINCT CONCAT(nivel_geografico, '|', codigo_geografico, '|', CAST(ano AS STRING)))
      THEN 'APROVADO'
      ELSE 'ALERTA'
    END,
    'Validação de unicidade da tabela temporal.'
  FROM `tech-alfabetizacao-vdemarchi.gold.evolucao_alfabetizacao`

  UNION ALL

  SELECT
    'STREAMING_BRONZE',
    COUNT(*),
    COUNTIF(event_id IS NULL OR dado_simulado IS NOT TRUE),
    NULL,
    NULL,
    CASE WHEN COUNTIF(event_id IS NULL OR dado_simulado IS NOT TRUE) = 0 THEN 'APROVADO' ELSE 'ALERTA' END,
    'Eventos recebidos na Bronze.'
  FROM `tech-alfabetizacao-vdemarchi.bronze.eventos_streaming`

  UNION ALL

  SELECT
    'STREAMING_SILVER',
    COUNT(*),
    COUNTIF(NOT registro_valido),
    NULL,
    NULL,
    CASE WHEN COUNTIF(NOT registro_valido) = 0 THEN 'APROVADO' ELSE 'ALERTA' END,
    'Eventos deduplicados e validados.'
  FROM `tech-alfabetizacao-vdemarchi.silver.eventos_streaming`

  UNION ALL

  SELECT
    'STREAMING_GOLD',
    COUNT(*),
    COUNTIF(dado_simulado IS NOT TRUE OR latencia_segundos < 0),
    AVG(CAST(latencia_segundos AS FLOAT64)),
    MAX(latencia_segundos),
    CASE
      WHEN COUNTIF(dado_simulado IS NOT TRUE OR latencia_segundos < 0) = 0
      THEN 'APROVADO'
      ELSE 'ALERTA'
    END,
    'Último evento válido por município.'
  FROM `tech-alfabetizacao-vdemarchi.gold.indicador_streaming`
)
SELECT
  *,
  CURRENT_TIMESTAMP() AS data_execucao
FROM metricas;
