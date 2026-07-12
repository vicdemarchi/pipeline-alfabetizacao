CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.silver.alunos`
PARTITION BY _data_particao
CLUSTER BY id_municipio, id_escola
AS
SELECT
  ano,
  NULLIF(TRIM(id_municipio), '') AS id_municipio,
  NULLIF(TRIM(id_escola), '') AS id_escola,
  NULLIF(TRIM(id_aluno), '') AS id_aluno,
  NULLIF(TRIM(caderno), '') AS caderno,
  SAFE_CAST(serie AS INT64) AS serie_codigo,
  CASE SAFE_CAST(serie AS INT64)
    WHEN 2 THEN '2º ano do Ensino Fundamental'
    ELSE 'Não mapeado'
  END AS serie_descricao,
  SAFE_CAST(rede AS INT64) AS rede_codigo,
  CASE SAFE_CAST(rede AS INT64)
    WHEN 1 THEN 'Federal'
    WHEN 2 THEN 'Estadual'
    WHEN 3 THEN 'Municipal'
    WHEN 4 THEN 'Privada'
    ELSE 'Não mapeada'
  END AS rede_nome,
  SAFE_CAST(presenca AS INT64) AS presenca_codigo,
  CASE SAFE_CAST(presenca AS INT64)
    WHEN 0 THEN 'Ausente'
    WHEN 1 THEN 'Presente'
    ELSE 'Não informado'
  END AS presenca_descricao,
  SAFE_CAST(preenchimento_caderno AS INT64) AS preenchimento_caderno_codigo,
  CASE SAFE_CAST(preenchimento_caderno AS INT64)
    WHEN 0 THEN 'Prova não preenchida'
    WHEN 1 THEN 'Prova preenchida'
    ELSE 'Não informado'
  END AS preenchimento_caderno_descricao,
  SAFE_CAST(alfabetizado AS INT64) AS alfabetizado_codigo,
  CASE SAFE_CAST(alfabetizado AS INT64)
    WHEN 0 THEN 'Não'
    WHEN 1 THEN 'Sim'
    ELSE 'Não informado'
  END AS alfabetizado_descricao,
  CASE
    WHEN SAFE_CAST(alfabetizado AS INT64) = 1 THEN TRUE
    WHEN SAFE_CAST(alfabetizado AS INT64) = 0 THEN FALSE
    ELSE NULL
  END AS alfabetizado_bool,
  proficiencia,
  peso_aluno,
  (
    ano IS NOT NULL
    AND NULLIF(TRIM(id_municipio), '') IS NOT NULL
    AND NULLIF(TRIM(id_aluno), '') IS NOT NULL
    AND SAFE_CAST(serie AS INT64) = 2
    AND SAFE_CAST(rede AS INT64) IN (1, 2, 3, 4)
    AND SAFE_CAST(presenca AS INT64) IN (0, 1)
    AND SAFE_CAST(preenchimento_caderno AS INT64) IN (0, 1)
    AND SAFE_CAST(alfabetizado AS INT64) IN (0, 1)
  ) AS registro_estrutural_valido,
  (
    SAFE_CAST(presenca AS INT64) = 1
    AND SAFE_CAST(preenchimento_caderno AS INT64) = 1
    AND SAFE_CAST(alfabetizado AS INT64) IN (0, 1)
    AND proficiencia IS NOT NULL
    AND peso_aluno IS NOT NULL
    AND peso_aluno > 0
  ) AS apto_analise_desempenho,
  _data_particao,
  _data_ingestao,
  _fonte
FROM `tech-alfabetizacao-vdemarchi.bronze.alunos`;
