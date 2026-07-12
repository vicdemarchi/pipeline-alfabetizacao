CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.gold.indicador_uf`
PARTITION BY _data_particao
CLUSTER BY ano, sigla_uf
AS
WITH metas AS (
  SELECT
    ano,
    sigla_uf,
    taxa_alfabetizacao AS taxa_alfabetizacao_tabela_meta,
    meta_alfabetizacao_2024,
    meta_alfabetizacao_2025,
    meta_alfabetizacao_2026,
    meta_alfabetizacao_2027,
    meta_alfabetizacao_2028,
    meta_alfabetizacao_2029,
    meta_alfabetizacao_2030,
    percentual_participacao
  FROM `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_uf`
  WHERE rede_nome = 'Pública' AND registro_estrutural_valido
),
resultados AS (
  SELECT
    ano,
    sigla_uf,
    taxa_alfabetizacao AS taxa_alfabetizacao_resultado,
    media_portugues,
    proporcao_aluno_nivel_0,
    proporcao_aluno_nivel_1,
    proporcao_aluno_nivel_2,
    proporcao_aluno_nivel_3,
    proporcao_aluno_nivel_4,
    proporcao_aluno_nivel_5,
    proporcao_aluno_nivel_6,
    proporcao_aluno_nivel_7,
    proporcao_aluno_nivel_8
  FROM `tech-alfabetizacao-vdemarchi.silver.uf`
  WHERE rede_codigo = 5 AND registro_estrutural_valido
),
integrado AS (
  SELECT
    COALESCE(m.ano, r.ano) AS ano,
    COALESCE(m.sigla_uf, r.sigla_uf) AS sigla_uf,
    m.sigla_uf IS NOT NULL AS tem_meta,
    r.sigla_uf IS NOT NULL AS tem_resultado,
    m.taxa_alfabetizacao_tabela_meta,
    r.taxa_alfabetizacao_resultado,
    m.meta_alfabetizacao_2024,
    m.meta_alfabetizacao_2025,
    m.meta_alfabetizacao_2026,
    m.meta_alfabetizacao_2027,
    m.meta_alfabetizacao_2028,
    m.meta_alfabetizacao_2029,
    m.meta_alfabetizacao_2030,
    m.percentual_participacao,
    r.media_portugues,
    r.proporcao_aluno_nivel_0,
    r.proporcao_aluno_nivel_1,
    r.proporcao_aluno_nivel_2,
    r.proporcao_aluno_nivel_3,
    r.proporcao_aluno_nivel_4,
    r.proporcao_aluno_nivel_5,
    r.proporcao_aluno_nivel_6,
    r.proporcao_aluno_nivel_7,
    r.proporcao_aluno_nivel_8
  FROM metas m
  FULL OUTER JOIN resultados r
    ON m.ano = r.ano AND m.sigla_uf = r.sigla_uf
),
com_meta_do_ano AS (
  SELECT *,
    CASE ano
      WHEN 2024 THEN meta_alfabetizacao_2024
      WHEN 2025 THEN meta_alfabetizacao_2025
      WHEN 2026 THEN meta_alfabetizacao_2026
      WHEN 2027 THEN meta_alfabetizacao_2027
      WHEN 2028 THEN meta_alfabetizacao_2028
      WHEN 2029 THEN meta_alfabetizacao_2029
      WHEN 2030 THEN meta_alfabetizacao_2030
    END AS meta_referencia_ano
  FROM integrado
)
SELECT
  ano,
  sigla_uf,
  tem_meta,
  tem_resultado,
  CASE
    WHEN NOT tem_meta THEN 'SOMENTE_RESULTADO'
    WHEN NOT tem_resultado THEN 'SOMENTE_META'
    WHEN taxa_alfabetizacao_tabela_meta IS NULL AND taxa_alfabetizacao_resultado IS NULL
      THEN 'CORRESPONDENTE_AMBAS_TAXAS_NULAS'
    WHEN taxa_alfabetizacao_tabela_meta IS NULL THEN 'CORRESPONDENTE_META_NULA'
    WHEN taxa_alfabetizacao_resultado IS NULL THEN 'CORRESPONDENTE_RESULTADO_NULO'
    WHEN ABS(taxa_alfabetizacao_tabela_meta - taxa_alfabetizacao_resultado) < 0.000001
      THEN 'CORRESPONDENTE_TAXAS_IGUAIS'
    ELSE 'CORRESPONDENTE_TAXAS_DIFERENTES'
  END AS status_relacionamento,
  taxa_alfabetizacao_tabela_meta,
  taxa_alfabetizacao_resultado,
  CASE
    WHEN taxa_alfabetizacao_tabela_meta IS NOT NULL
      AND taxa_alfabetizacao_resultado IS NOT NULL
    THEN ROUND(taxa_alfabetizacao_resultado - taxa_alfabetizacao_tabela_meta, 6)
  END AS diferenca_entre_fontes,
  meta_referencia_ano,
  CASE
    WHEN taxa_alfabetizacao_resultado IS NOT NULL AND meta_referencia_ano IS NOT NULL
    THEN ROUND(taxa_alfabetizacao_resultado - meta_referencia_ano, 2)
  END AS diferenca_resultado_meta_ano,
  CASE
    WHEN meta_referencia_ano IS NULL THEN 'SEM_META_PARA_O_ANO'
    WHEN taxa_alfabetizacao_resultado IS NULL THEN 'SEM_RESULTADO'
    WHEN taxa_alfabetizacao_resultado >= meta_referencia_ano THEN 'ATINGIU_OU_SUPEROU_A_META'
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
  media_portugues,
  proporcao_aluno_nivel_0,
  proporcao_aluno_nivel_1,
  proporcao_aluno_nivel_2,
  proporcao_aluno_nivel_3,
  proporcao_aluno_nivel_4,
  proporcao_aluno_nivel_5,
  proporcao_aluno_nivel_6,
  proporcao_aluno_nivel_7,
  proporcao_aluno_nivel_8,
  CURRENT_DATE('America/Sao_Paulo') AS _data_particao,
  CURRENT_TIMESTAMP() AS _data_processamento
FROM com_meta_do_ano;
