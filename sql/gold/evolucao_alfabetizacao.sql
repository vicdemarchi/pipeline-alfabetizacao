CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.gold.evolucao_alfabetizacao`
AS
SELECT
  'MUNICIPIO' AS nivel_geografico,
  id_municipio AS codigo_geografico,
  'Municipal' AS rede_nome,
  ano,
  taxa_alfabetizacao_resultado AS taxa_alfabetizacao_observada,
  taxa_alfabetizacao_tabela_meta AS taxa_registrada_na_tabela_de_metas,
  meta_referencia_ano,
  diferenca_resultado_meta_ano,
  situacao_meta_ano,
  tem_meta,
  tem_resultado,
  status_relacionamento,
  _data_processamento
FROM `tech-alfabetizacao-vdemarchi.gold.indicador_municipio`

UNION ALL

SELECT
  'UF',
  sigla_uf,
  'Pública',
  ano,
  taxa_alfabetizacao_resultado,
  taxa_alfabetizacao_tabela_meta,
  meta_referencia_ano,
  diferenca_resultado_meta_ano,
  situacao_meta_ano,
  tem_meta,
  tem_resultado,
  status_relacionamento,
  _data_processamento
FROM `tech-alfabetizacao-vdemarchi.gold.indicador_uf`

UNION ALL

SELECT
  'BRASIL',
  'BR',
  rede_nome,
  ano,
  taxa_alfabetizacao,
  CAST(NULL AS FLOAT64),
  meta_referencia_ano,
  diferenca_resultado_meta_ano,
  situacao_meta_ano,
  meta_referencia_ano IS NOT NULL,
  taxa_alfabetizacao IS NOT NULL,
  'FONTE_NACIONAL_UNICA',
  _data_processamento
FROM `tech-alfabetizacao-vdemarchi.gold.indicador_brasil`;
