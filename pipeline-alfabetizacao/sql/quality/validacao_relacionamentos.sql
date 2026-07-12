CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.quality.validacao_relacionamentos`
AS
WITH meta_municipio AS (
  SELECT ano, id_municipio, taxa_alfabetizacao AS taxa_meta
  FROM `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_municipio`
  WHERE rede_nome = 'Municipal'
),
resultado_municipio AS (
  SELECT ano, id_municipio, taxa_alfabetizacao AS taxa_resultado
  FROM `tech-alfabetizacao-vdemarchi.silver.municipio`
  WHERE rede_codigo = 3
),
meta_uf AS (
  SELECT ano, sigla_uf, taxa_alfabetizacao AS taxa_meta
  FROM `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_uf`
  WHERE rede_nome = 'Pública' AND ano IN (2023, 2024)
),
resultado_uf AS (
  SELECT ano, sigla_uf, taxa_alfabetizacao AS taxa_resultado
  FROM `tech-alfabetizacao-vdemarchi.silver.uf`
  WHERE rede_codigo = 5
),
comparacoes AS (
  SELECT
    'municipio' AS nivel,
    COALESCE(m.ano, r.ano) AS ano,
    m.id_municipio AS chave_meta,
    r.id_municipio AS chave_resultado,
    m.taxa_meta,
    r.taxa_resultado
  FROM meta_municipio m
  FULL OUTER JOIN resultado_municipio r
    ON m.ano = r.ano AND m.id_municipio = r.id_municipio
  UNION ALL
  SELECT
    'uf',
    COALESCE(m.ano, r.ano),
    m.sigla_uf,
    r.sigla_uf,
    m.taxa_meta,
    r.taxa_resultado
  FROM meta_uf m
  FULL OUTER JOIN resultado_uf r
    ON m.ano = r.ano AND m.sigla_uf = r.sigla_uf
),
classificacao AS (
  SELECT
    *,
    CASE
      WHEN chave_meta IS NULL THEN 'SOMENTE_RESULTADO'
      WHEN chave_resultado IS NULL THEN 'SOMENTE_META'
      WHEN taxa_meta IS NULL AND taxa_resultado IS NULL THEN 'CORRESPONDENTE_AMBAS_TAXAS_NULAS'
      WHEN taxa_meta IS NULL THEN 'CORRESPONDENTE_META_NULA'
      WHEN taxa_resultado IS NULL THEN 'CORRESPONDENTE_RESULTADO_NULO'
      WHEN ABS(taxa_meta - taxa_resultado) < 0.000001 THEN 'CORRESPONDENTE_TAXAS_IGUAIS'
      ELSE 'CORRESPONDENTE_TAXAS_DIFERENTES'
    END AS status_relacionamento,
    CASE
      WHEN taxa_meta IS NOT NULL AND taxa_resultado IS NOT NULL
      THEN ABS(taxa_meta - taxa_resultado)
    END AS diferenca_absoluta
  FROM comparacoes
)
SELECT
  nivel,
  ano,
  status_relacionamento,
  COUNT(*) AS quantidade_registros,
  ROUND(MIN(diferenca_absoluta), 6) AS menor_diferenca_absoluta,
  ROUND(AVG(diferenca_absoluta), 6) AS media_diferenca_absoluta,
  ROUND(MAX(diferenca_absoluta), 6) AS maior_diferenca_absoluta,
  CURRENT_TIMESTAMP() AS data_execucao
FROM classificacao
GROUP BY nivel, ano, status_relacionamento;
