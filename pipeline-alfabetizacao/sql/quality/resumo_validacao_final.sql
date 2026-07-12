-- ============================================================
-- QUALITY.RESUMO_VALIDACAO_FINAL
--
-- Consolida controles de:
-- - Volume Bronze x Silver;
-- - Registros inválidos;
-- - Chaves ausentes;
-- - Duplicidades;
-- - Taxas fora do intervalo;
-- - Unicidade e consistência das tabelas Gold;
-- - Informações relevantes da fonte.
--
-- Regras críticas devem resultar em APROVADO.
-- Características reais da fonte ficam como INFORMATIVO.
-- ============================================================

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.quality.resumo_validacao_final`
AS

WITH

alunos_metricas AS (
  SELECT
    (
      SELECT COUNT(*)
      FROM `tech-alfabetizacao-vdemarchi.bronze.alunos`
    ) AS total_bronze,
    COUNT(*) AS total_silver,
    COUNTIF(
      NOT COALESCE(registro_estrutural_valido, FALSE)
    ) AS registros_invalidos,
    COUNTIF(
      ano IS NULL
      OR id_municipio IS NULL
      OR id_aluno IS NULL
    ) AS chaves_ausentes,
    COUNT(*) - COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          id_aluno AS id_aluno
        )
      )
    ) AS duplicidades,
    COUNTIF(
      NOT COALESCE(apto_analise_desempenho, FALSE)
    ) AS registros_nao_aptos
  FROM
    `tech-alfabetizacao-vdemarchi.silver.alunos`
),

meta_brasil_metricas AS (
  SELECT
    (
      SELECT COUNT(*)
      FROM
        `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_brasil`
    ) AS total_bronze,
    COUNT(*) AS total_silver,
    COUNTIF(
      NOT COALESCE(registro_estrutural_valido, FALSE)
    ) AS registros_invalidos,
    COUNTIF(
      ano IS NULL
      OR rede_nome IS NULL
    ) AS chaves_ausentes,
    COUNT(*) - COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          rede_nome AS rede_nome
        )
      )
    ) AS duplicidades,
    COUNTIF(
      taxa_alfabetizacao IS NULL
    ) AS taxas_ausentes,
    COUNTIF(
      taxa_alfabetizacao IS NOT NULL
      AND NOT (taxa_alfabetizacao BETWEEN 0 AND 100)
    ) AS taxas_fora_intervalo
  FROM
    `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_brasil`
),

meta_municipio_metricas AS (
  SELECT
    (
      SELECT COUNT(*)
      FROM
        `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_municipio`
    ) AS total_bronze,
    COUNT(*) AS total_silver,
    COUNTIF(
      NOT COALESCE(registro_estrutural_valido, FALSE)
    ) AS registros_invalidos,
    COUNTIF(
      ano IS NULL
      OR id_municipio IS NULL
      OR rede_nome IS NULL
    ) AS chaves_ausentes,
    COUNT(*) - COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          id_municipio AS id_municipio,
          rede_nome AS rede_nome
        )
      )
    ) AS duplicidades,
    COUNTIF(
      taxa_alfabetizacao IS NULL
    ) AS taxas_ausentes,
    COUNTIF(
      taxa_alfabetizacao IS NOT NULL
      AND NOT (taxa_alfabetizacao BETWEEN 0 AND 100)
    ) AS taxas_fora_intervalo
  FROM
    `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_municipio`
),

meta_uf_metricas AS (
  SELECT
    (
      SELECT COUNT(*)
      FROM
        `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_uf`
    ) AS total_bronze,
    COUNT(*) AS total_silver,
    COUNTIF(
      NOT COALESCE(registro_estrutural_valido, FALSE)
    ) AS registros_invalidos,
    COUNTIF(
      ano IS NULL
      OR sigla_uf IS NULL
      OR rede_nome IS NULL
    ) AS chaves_ausentes,
    COUNT(*) - COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          sigla_uf AS sigla_uf,
          rede_nome AS rede_nome
        )
      )
    ) AS duplicidades,
    COUNTIF(
      taxa_alfabetizacao IS NULL
    ) AS taxas_ausentes,
    COUNTIF(
      taxa_alfabetizacao IS NOT NULL
      AND NOT (taxa_alfabetizacao BETWEEN 0 AND 100)
    ) AS taxas_fora_intervalo
  FROM
    `tech-alfabetizacao-vdemarchi.silver.meta_alfabetizacao_uf`
),

municipio_metricas AS (
  SELECT
    (
      SELECT COUNT(*)
      FROM
        `tech-alfabetizacao-vdemarchi.bronze.municipio`
    ) AS total_bronze,
    COUNT(*) AS total_silver,
    COUNTIF(
      NOT COALESCE(registro_estrutural_valido, FALSE)
    ) AS registros_invalidos,
    COUNTIF(
      ano IS NULL
      OR id_municipio IS NULL
      OR serie_codigo IS NULL
      OR rede_codigo IS NULL
    ) AS chaves_ausentes,
    COUNT(*) - COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          id_municipio AS id_municipio,
          serie_codigo AS serie_codigo,
          rede_codigo AS rede_codigo
        )
      )
    ) AS duplicidades,
    COUNTIF(
      taxa_alfabetizacao IS NULL
    ) AS taxas_ausentes,
    COUNTIF(
      taxa_alfabetizacao IS NOT NULL
      AND NOT (taxa_alfabetizacao BETWEEN 0 AND 100)
    ) AS taxas_fora_intervalo
  FROM
    `tech-alfabetizacao-vdemarchi.silver.municipio`
),

uf_metricas AS (
  SELECT
    (
      SELECT COUNT(*)
      FROM
        `tech-alfabetizacao-vdemarchi.bronze.uf`
    ) AS total_bronze,
    COUNT(*) AS total_silver,
    COUNTIF(
      NOT COALESCE(registro_estrutural_valido, FALSE)
    ) AS registros_invalidos,
    COUNTIF(
      ano IS NULL
      OR sigla_uf IS NULL
      OR serie_codigo IS NULL
      OR rede_codigo IS NULL
    ) AS chaves_ausentes,
    COUNT(*) - COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          sigla_uf AS sigla_uf,
          serie_codigo AS serie_codigo,
          rede_codigo AS rede_codigo
        )
      )
    ) AS duplicidades,
    COUNTIF(
      taxa_alfabetizacao IS NULL
    ) AS taxas_ausentes,
    COUNTIF(
      taxa_alfabetizacao IS NOT NULL
      AND NOT (taxa_alfabetizacao BETWEEN 0 AND 100)
    ) AS taxas_fora_intervalo
  FROM
    `tech-alfabetizacao-vdemarchi.silver.uf`
),

gold_municipio_metricas AS (
  SELECT
    COUNT(*) AS total_linhas,
    COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          id_municipio AS id_municipio
        )
      )
    ) AS chaves_distintas,
    COUNTIF(
      ano IS NULL
      OR id_municipio IS NULL
    ) AS chaves_ausentes,
    COUNTIF(
      meta_referencia_ano IS NOT NULL
      AND taxa_alfabetizacao_resultado IS NOT NULL
    ) AS comparacoes_validas,
    COUNTIF(
      situacao_meta_ano IN (
        'ATINGIU_OU_SUPEROU_A_META',
        'ABAIXO_DA_META'
      )
    ) AS comparacoes_classificadas
  FROM
    `tech-alfabetizacao-vdemarchi.gold.indicador_municipio`
),

gold_uf_metricas AS (
  SELECT
    COUNT(*) AS total_linhas,
    COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          sigla_uf AS sigla_uf
        )
      )
    ) AS chaves_distintas,
    COUNTIF(
      ano IS NULL
      OR sigla_uf IS NULL
    ) AS chaves_ausentes,
    COUNTIF(
      meta_referencia_ano IS NOT NULL
      AND taxa_alfabetizacao_resultado IS NOT NULL
    ) AS comparacoes_validas,
    COUNTIF(
      situacao_meta_ano IN (
        'ATINGIU_OU_SUPEROU_A_META',
        'ABAIXO_DA_META'
      )
    ) AS comparacoes_classificadas
  FROM
    `tech-alfabetizacao-vdemarchi.gold.indicador_uf`
),

gold_brasil_metricas AS (
  SELECT
    COUNT(*) AS total_linhas,
    COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          ano AS ano,
          rede_nome AS rede_nome
        )
      )
    ) AS chaves_distintas,
    COUNTIF(
      ano IS NULL
      OR rede_nome IS NULL
    ) AS chaves_ausentes,
    COUNTIF(
      meta_referencia_ano IS NOT NULL
      AND taxa_alfabetizacao IS NOT NULL
    ) AS comparacoes_validas,
    COUNTIF(
      situacao_meta_ano IN (
        'ATINGIU_OU_SUPEROU_A_META',
        'ABAIXO_DA_META'
      )
    ) AS comparacoes_classificadas
  FROM
    `tech-alfabetizacao-vdemarchi.gold.indicador_brasil`
),

gold_evolucao_metricas AS (
  SELECT
    COUNT(*) AS total_linhas,
    COUNT(
      DISTINCT TO_JSON_STRING(
        STRUCT(
          nivel_geografico AS nivel_geografico,
          codigo_geografico AS codigo_geografico,
          ano AS ano
        )
      )
    ) AS chaves_distintas,
    COUNTIF(
      nivel_geografico IS NULL
      OR codigo_geografico IS NULL
      OR ano IS NULL
    ) AS chaves_ausentes,
    COUNTIF(
      meta_referencia_ano IS NOT NULL
      AND taxa_alfabetizacao_observada IS NOT NULL
    ) AS comparacoes_validas,
    COUNTIF(
      situacao_meta_ano IN (
        'ATINGIU_OU_SUPEROU_A_META',
        'ABAIXO_DA_META'
      )
    ) AS comparacoes_classificadas
  FROM
    `tech-alfabetizacao-vdemarchi.gold.evolucao_alfabetizacao`
),

regras AS (

  SELECT
    'BRONZE_SILVER' AS camada,
    'alunos' AS objeto,
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM alunos_metricas,
  UNNEST([
    STRUCT(
      'DIFERENCA_DE_VOLUME' AS regra,
      ABS(total_bronze - total_silver) AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'Bronze e Silver devem possuir o mesmo número de linhas.'
        AS detalhe
    ),
    STRUCT(
      'REGISTROS_ESTRUTURALMENTE_INVALIDOS',
      registros_invalidos,
      0,
      'CRITICA',
      'Registros que não atendem às regras estruturais.'
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano, município e identificador do aluno são obrigatórios.'
    ),
    STRUCT(
      'DUPLICIDADES_NA_CHAVE',
      duplicidades,
      0,
      'CRITICA',
      'Verificação pela combinação de ano e identificador do aluno.'
    ),
    STRUCT(
      'REGISTROS_NAO_APTOS_PARA_DESEMPENHO',
      registros_nao_aptos,
      CAST(NULL AS INT64),
      'INFORMATIVA',
      'Inclui ausentes e provas não preenchidas; não representa erro estrutural.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'BRONZE_SILVER',
    'meta_alfabetizacao_brasil',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM meta_brasil_metricas,
  UNNEST([
    STRUCT(
      'DIFERENCA_DE_VOLUME' AS regra,
      ABS(total_bronze - total_silver) AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'Bronze e Silver devem possuir o mesmo número de linhas.'
        AS detalhe
    ),
    STRUCT(
      'REGISTROS_ESTRUTURALMENTE_INVALIDOS',
      registros_invalidos,
      0,
      'CRITICA',
      'Registros estruturalmente inválidos.'
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano e rede são obrigatórios.'
    ),
    STRUCT(
      'DUPLICIDADES_NA_CHAVE',
      duplicidades,
      0,
      'CRITICA',
      'Verificação pela combinação de ano e rede.'
    ),
    STRUCT(
      'TAXAS_FORA_DO_INTERVALO',
      taxas_fora_intervalo,
      0,
      'CRITICA',
      'Taxas válidas devem estar entre 0 e 100.'
    ),
    STRUCT(
      'TAXAS_AUSENTES',
      taxas_ausentes,
      CAST(NULL AS INT64),
      'INFORMATIVA',
      'Ausências da fonte são preservadas como NULL.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'BRONZE_SILVER',
    'meta_alfabetizacao_municipio',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM meta_municipio_metricas,
  UNNEST([
    STRUCT(
      'DIFERENCA_DE_VOLUME' AS regra,
      ABS(total_bronze - total_silver) AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'Bronze e Silver devem possuir o mesmo número de linhas.'
        AS detalhe
    ),
    STRUCT(
      'REGISTROS_ESTRUTURALMENTE_INVALIDOS',
      registros_invalidos,
      0,
      'CRITICA',
      'Registros estruturalmente inválidos.'
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano, município e rede são obrigatórios.'
    ),
    STRUCT(
      'DUPLICIDADES_NA_CHAVE',
      duplicidades,
      0,
      'CRITICA',
      'Verificação por ano, município e rede.'
    ),
    STRUCT(
      'TAXAS_FORA_DO_INTERVALO',
      taxas_fora_intervalo,
      0,
      'CRITICA',
      'Taxas válidas devem estar entre 0 e 100.'
    ),
    STRUCT(
      'TAXAS_AUSENTES',
      taxas_ausentes,
      CAST(NULL AS INT64),
      'INFORMATIVA',
      'Foram identificadas ausências reais na fonte.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'BRONZE_SILVER',
    'meta_alfabetizacao_uf',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM meta_uf_metricas,
  UNNEST([
    STRUCT(
      'DIFERENCA_DE_VOLUME' AS regra,
      ABS(total_bronze - total_silver) AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'Bronze e Silver devem possuir o mesmo número de linhas.'
        AS detalhe
    ),
    STRUCT(
      'REGISTROS_ESTRUTURALMENTE_INVALIDOS',
      registros_invalidos,
      0,
      'CRITICA',
      'Registros estruturalmente inválidos.'
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano, UF e rede são obrigatórios.'
    ),
    STRUCT(
      'DUPLICIDADES_NA_CHAVE',
      duplicidades,
      0,
      'CRITICA',
      'Verificação por ano, UF e rede.'
    ),
    STRUCT(
      'TAXAS_FORA_DO_INTERVALO',
      taxas_fora_intervalo,
      0,
      'CRITICA',
      'Taxas válidas devem estar entre 0 e 100.'
    ),
    STRUCT(
      'TAXAS_AUSENTES',
      taxas_ausentes,
      CAST(NULL AS INT64),
      'INFORMATIVA',
      'Foram identificadas ausências reais na fonte.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'BRONZE_SILVER',
    'municipio',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM municipio_metricas,
  UNNEST([
    STRUCT(
      'DIFERENCA_DE_VOLUME' AS regra,
      ABS(total_bronze - total_silver) AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'Bronze e Silver devem possuir o mesmo número de linhas.'
        AS detalhe
    ),
    STRUCT(
      'REGISTROS_ESTRUTURALMENTE_INVALIDOS',
      registros_invalidos,
      0,
      'CRITICA',
      'Registros estruturalmente inválidos.'
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano, município, série e rede são obrigatórios.'
    ),
    STRUCT(
      'DUPLICIDADES_NA_CHAVE',
      duplicidades,
      0,
      'CRITICA',
      'Verificação por ano, município, série e rede.'
    ),
    STRUCT(
      'TAXAS_FORA_DO_INTERVALO',
      taxas_fora_intervalo,
      0,
      'CRITICA',
      'Taxas válidas devem estar entre 0 e 100.'
    ),
    STRUCT(
      'TAXAS_AUSENTES',
      taxas_ausentes,
      CAST(NULL AS INT64),
      'INFORMATIVA',
      'Ausências da fonte são preservadas como NULL.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'BRONZE_SILVER',
    'uf',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM uf_metricas,
  UNNEST([
    STRUCT(
      'DIFERENCA_DE_VOLUME' AS regra,
      ABS(total_bronze - total_silver) AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'Bronze e Silver devem possuir o mesmo número de linhas.'
        AS detalhe
    ),
    STRUCT(
      'REGISTROS_ESTRUTURALMENTE_INVALIDOS',
      registros_invalidos,
      0,
      'CRITICA',
      'Registros estruturalmente inválidos.'
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano, UF, série e rede são obrigatórios.'
    ),
    STRUCT(
      'DUPLICIDADES_NA_CHAVE',
      duplicidades,
      0,
      'CRITICA',
      'Verificação por ano, UF, série e rede.'
    ),
    STRUCT(
      'TAXAS_FORA_DO_INTERVALO',
      taxas_fora_intervalo,
      0,
      'CRITICA',
      'Taxas válidas devem estar entre 0 e 100.'
    ),
    STRUCT(
      'TAXAS_AUSENTES',
      taxas_ausentes,
      CAST(NULL AS INT64),
      'INFORMATIVA',
      'Ausências da fonte são preservadas como NULL.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'GOLD',
    'indicador_municipio',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM gold_municipio_metricas,
  UNNEST([
    STRUCT(
      'DUPLICIDADES_NA_CHAVE' AS regra,
      total_linhas - chaves_distintas AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'A chave ano e município deve ser única.'
        AS detalhe
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano e município são obrigatórios.'
    ),
    STRUCT(
      'COMPARACOES_NAO_CLASSIFICADAS',
      ABS(comparacoes_validas - comparacoes_classificadas),
      0,
      'CRITICA',
      'Toda comparação válida deve ser classificada.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'GOLD',
    'indicador_uf',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM gold_uf_metricas,
  UNNEST([
    STRUCT(
      'DUPLICIDADES_NA_CHAVE' AS regra,
      total_linhas - chaves_distintas AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'A chave ano e UF deve ser única.'
        AS detalhe
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano e UF são obrigatórios.'
    ),
    STRUCT(
      'COMPARACOES_NAO_CLASSIFICADAS',
      ABS(comparacoes_validas - comparacoes_classificadas),
      0,
      'CRITICA',
      'Toda comparação válida deve ser classificada.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'GOLD',
    'indicador_brasil',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM gold_brasil_metricas,
  UNNEST([
    STRUCT(
      'DUPLICIDADES_NA_CHAVE' AS regra,
      total_linhas - chaves_distintas AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'A chave ano e rede deve ser única.'
        AS detalhe
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Ano e rede são obrigatórios.'
    ),
    STRUCT(
      'COMPARACOES_NAO_CLASSIFICADAS',
      ABS(comparacoes_validas - comparacoes_classificadas),
      0,
      'CRITICA',
      'Toda comparação válida deve ser classificada.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'GOLD',
    'evolucao_alfabetizacao',
    regra.regra,
    regra.valor_observado,
    regra.valor_esperado,
    regra.severidade,
    regra.detalhe
  FROM gold_evolucao_metricas,
  UNNEST([
    STRUCT(
      'DUPLICIDADES_NA_CHAVE' AS regra,
      total_linhas - chaves_distintas AS valor_observado,
      0 AS valor_esperado,
      'CRITICA' AS severidade,
      'A chave nível, localidade e ano deve ser única.'
        AS detalhe
    ),
    STRUCT(
      'CHAVES_AUSENTES',
      chaves_ausentes,
      0,
      'CRITICA',
      'Nível, código geográfico e ano são obrigatórios.'
    ),
    STRUCT(
      'COMPARACOES_NAO_CLASSIFICADAS',
      ABS(comparacoes_validas - comparacoes_classificadas),
      0,
      'CRITICA',
      'Toda comparação válida deve ser classificada.'
    )
  ]) AS regra

  UNION ALL

  SELECT
    'RELACIONAMENTOS' AS camada,
    CONCAT(
      nivel,
      '_',
      CAST(ano AS STRING)
    ) AS objeto,
    status_relacionamento AS regra,
    quantidade_registros AS valor_observado,
    CAST(NULL AS INT64) AS valor_esperado,
    'INFORMATIVA' AS severidade,
    'Cobertura e consistência observadas entre as tabelas de metas e resultados.'
      AS detalhe
  FROM
    `tech-alfabetizacao-vdemarchi.quality.validacao_relacionamentos`
)

SELECT
  camada,
  objeto,
  regra,
  valor_observado,
  valor_esperado,
  severidade,
  CASE
    WHEN severidade = 'INFORMATIVA'
      THEN 'INFORMATIVO'
    WHEN valor_observado = valor_esperado
      THEN 'APROVADO'
    ELSE 'REVISAR'
  END AS status,
  detalhe,
  CURRENT_TIMESTAMP() AS data_execucao
FROM regras;
