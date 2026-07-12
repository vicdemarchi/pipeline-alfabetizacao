CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_brasil`
PARTITION BY _data_particao
AS
SELECT
  ano,
  NULLIF(REGEXP_REPLACE(TRIM(rede), r'\s+', ' '), '') AS rede_nome,
  taxa_alfabetizacao,
  meta_alfabetizacao_2024,
  meta_alfabetizacao_2025,
  meta_alfabetizacao_2026,
  meta_alfabetizacao_2027,
  meta_alfabetizacao_2028,
  meta_alfabetizacao_2029,
  meta_alfabetizacao_2030,
  percentual_participacao,
  (ano IS NOT NULL AND NULLIF(TRIM(rede), '') IS NOT NULL) AS registro_estrutural_valido,
  _data_particao,
  _data_ingestao,
  _fonte
FROM `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_brasil`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_municipio`
PARTITION BY _data_particao
CLUSTER BY id_municipio
AS
SELECT
  ano,
  NULLIF(TRIM(id_municipio), '') AS id_municipio,
  NULLIF(REGEXP_REPLACE(TRIM(rede), r'\s+', ' '), '') AS rede_nome,
  taxa_alfabetizacao,
  meta_alfabetizacao_2024,
  meta_alfabetizacao_2025,
  meta_alfabetizacao_2026,
  meta_alfabetizacao_2027,
  meta_alfabetizacao_2028,
  meta_alfabetizacao_2029,
  meta_alfabetizacao_2030,
  nivel_alfabetizacao,
  percentual_participacao,
  (
    ano IS NOT NULL
    AND NULLIF(TRIM(id_municipio), '') IS NOT NULL
    AND NULLIF(TRIM(rede), '') IS NOT NULL
  ) AS registro_estrutural_valido,
  _data_particao,
  _data_ingestao,
  _fonte
FROM `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_municipio`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_uf`
PARTITION BY _data_particao
CLUSTER BY sigla_uf
AS
SELECT
  ano,
  UPPER(NULLIF(TRIM(sigla_uf), '')) AS sigla_uf,
  NULLIF(REGEXP_REPLACE(TRIM(rede), r'\s+', ' '), '') AS rede_nome,
  taxa_alfabetizacao,
  meta_alfabetizacao_2024,
  meta_alfabetizacao_2025,
  meta_alfabetizacao_2026,
  meta_alfabetizacao_2027,
  meta_alfabetizacao_2028,
  meta_alfabetizacao_2029,
  meta_alfabetizacao_2030,
  percentual_participacao,
  (
    ano IS NOT NULL
    AND NULLIF(TRIM(sigla_uf), '') IS NOT NULL
    AND NULLIF(TRIM(rede), '') IS NOT NULL
  ) AS registro_estrutural_valido,
  _data_particao,
  _data_ingestao,
  _fonte
FROM `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_uf`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.silver.municipio`
PARTITION BY _data_particao
CLUSTER BY id_municipio, rede_codigo
AS
SELECT
  ano,
  NULLIF(TRIM(id_municipio), '') AS id_municipio,
  SAFE_CAST(serie AS INT64) AS serie_codigo,
  CASE SAFE_CAST(serie AS INT64)
    WHEN 2 THEN '2º ano do Ensino Fundamental'
    ELSE 'Não mapeado'
  END AS serie_descricao,
  SAFE_CAST(rede AS INT64) AS rede_codigo,
  CASE SAFE_CAST(rede AS INT64)
    WHEN 0 THEN 'Total'
    WHEN 1 THEN 'Federal'
    WHEN 2 THEN 'Estadual'
    WHEN 3 THEN 'Municipal'
    WHEN 4 THEN 'Privada'
    WHEN 5 THEN 'Pública — Estadual e Municipal'
    WHEN 6 THEN 'Pública — Federal, Estadual e Municipal'
    ELSE 'Não mapeada'
  END AS rede_nome,
  taxa_alfabetizacao,
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
  (
    ano IS NOT NULL
    AND NULLIF(TRIM(id_municipio), '') IS NOT NULL
    AND SAFE_CAST(serie AS INT64) = 2
    AND SAFE_CAST(rede AS INT64) IN (0, 1, 2, 3, 4, 5, 6)
  ) AS registro_estrutural_valido,
  _data_particao,
  _data_ingestao,
  _fonte
FROM `tech-alfabetizacao-vdemarchi.bronze.municipio`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.silver.uf`
PARTITION BY _data_particao
CLUSTER BY sigla_uf, rede_codigo
AS
SELECT
  ano,
  UPPER(NULLIF(TRIM(sigla_uf), '')) AS sigla_uf,
  SAFE_CAST(serie AS INT64) AS serie_codigo,
  CASE SAFE_CAST(serie AS INT64)
    WHEN 2 THEN '2º ano do Ensino Fundamental'
    ELSE 'Não mapeado'
  END AS serie_descricao,
  SAFE_CAST(rede AS INT64) AS rede_codigo,
  CASE SAFE_CAST(rede AS INT64)
    WHEN 0 THEN 'Total'
    WHEN 1 THEN 'Federal'
    WHEN 2 THEN 'Estadual'
    WHEN 3 THEN 'Municipal'
    WHEN 4 THEN 'Privada'
    WHEN 5 THEN 'Pública — Estadual e Municipal'
    WHEN 6 THEN 'Pública — Federal, Estadual e Municipal'
    ELSE 'Não mapeada'
  END AS rede_nome,
  taxa_alfabetizacao,
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
  (
    ano IS NOT NULL
    AND NULLIF(TRIM(sigla_uf), '') IS NOT NULL
    AND SAFE_CAST(serie AS INT64) = 2
    AND SAFE_CAST(rede AS INT64) IN (0, 1, 2, 3, 4, 5, 6)
  ) AS registro_estrutural_valido,
  _data_particao,
  _data_ingestao,
  _fonte
FROM `tech-alfabetizacao-vdemarchi.bronze.uf`;
