CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.gold.indicador_brasil`
AS
WITH base AS (
  SELECT
    ano,
    rede_nome,
    taxa_alfabetizacao,
    meta_alfabetizacao_2024,
    meta_alfabetizacao_2025,
    meta_alfabetizacao_2026,
    meta_alfabetizacao_2027,
    meta_alfabetizacao_2028,
    meta_alfabetizacao_2029,
    meta_alfabetizacao_2030,
    percentual_participacao,
    CASE ano
      WHEN 2024 THEN meta_alfabetizacao_2024
      WHEN 2025 THEN meta_alfabetizacao_2025
      WHEN 2026 THEN meta_alfabetizacao_2026
      WHEN 2027 THEN meta_alfabetizacao_2027
      WHEN 2028 THEN meta_alfabetizacao_2028
      WHEN 2029 THEN meta_alfabetizacao_2029
      WHEN 2030 THEN meta_alfabetizacao_2030
      ELSE NULL
    END AS meta_referencia_ano
  FROM `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_brasil`
  WHERE registro_estrutural_valido
)
SELECT
  ano,
  rede_nome,
  taxa_alfabetizacao,
  meta_referencia_ano,
  CASE
    WHEN taxa_alfabetizacao IS NOT NULL AND meta_referencia_ano IS NOT NULL
    THEN ROUND(taxa_alfabetizacao - meta_referencia_ano, 2)
  END AS diferenca_resultado_meta_ano,
  CASE
    WHEN meta_referencia_ano IS NULL THEN 'SEM_META_PARA_O_ANO'
    WHEN taxa_alfabetizacao IS NULL THEN 'SEM_RESULTADO'
    WHEN taxa_alfabetizacao >= meta_referencia_ano THEN 'ATINGIU_OU_SUPEROU_A_META'
    ELSE 'ABAIXO_DA_META'
  END AS situacao_meta_ano,
  meta_alfabetizacao_2024,
  meta_alfabetizacao_2025,
  meta_alfabetizacao_2026,
  meta_alfabetizacao_2027,
  meta_alfabetizacao_2028,
  meta_alfabetizacao_2029,
  meta_alfabetizacao_2030,
  percentual_participacao,
  CURRENT_TIMESTAMP() AS _data_processamento
FROM base;
