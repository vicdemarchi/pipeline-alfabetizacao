-- CAMADA BRONZE
-- Particionamento pela data atual de ingestão.

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.bronze.alunos`
PARTITION BY _data_particao
AS
SELECT
  ano,
  id_municipio,
  id_escola,
  id_aluno,
  caderno,
  serie,
  rede,
  presenca,
  preenchimento_caderno,
  alfabetizado,
  proficiencia,
  peso_aluno,
  CURRENT_DATE('America/Sao_Paulo') AS _data_particao,
  CURRENT_TIMESTAMP() AS _data_ingestao,
  'basedosdados.br_inep_avaliacao_alfabetizacao.alunos' AS _fonte
FROM `basedosdados.br_inep_avaliacao_alfabetizacao.alunos`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_brasil`
PARTITION BY _data_particao
AS
SELECT
  ano,
  rede,
  taxa_alfabetizacao,
  meta_alfabetizacao_2024,
  meta_alfabetizacao_2025,
  meta_alfabetizacao_2026,
  meta_alfabetizacao_2027,
  meta_alfabetizacao_2028,
  meta_alfabetizacao_2029,
  meta_alfabetizacao_2030,
  percentual_participacao,
  CURRENT_DATE('America/Sao_Paulo') AS _data_particao,
  CURRENT_TIMESTAMP() AS _data_ingestao,
  'basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_brasil' AS _fonte
FROM `basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_brasil`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_municipio`
PARTITION BY _data_particao
AS
SELECT
  ano,
  id_municipio,
  rede,
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
  CURRENT_DATE('America/Sao_Paulo') AS _data_particao,
  CURRENT_TIMESTAMP() AS _data_ingestao,
  'basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_municipio' AS _fonte
FROM `basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_municipio`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.bronze.meta_alfabetizacao_uf`
PARTITION BY _data_particao
AS
SELECT
  ano,
  sigla_uf,
  rede,
  taxa_alfabetizacao,
  meta_alfabetizacao_2024,
  meta_alfabetizacao_2025,
  meta_alfabetizacao_2026,
  meta_alfabetizacao_2027,
  meta_alfabetizacao_2028,
  meta_alfabetizacao_2029,
  meta_alfabetizacao_2030,
  percentual_participacao,
  CURRENT_DATE('America/Sao_Paulo') AS _data_particao,
  CURRENT_TIMESTAMP() AS _data_ingestao,
  'basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_uf' AS _fonte
FROM `basedosdados.br_inep_avaliacao_alfabetizacao.meta_alfabetizacao_uf`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.bronze.municipio`
PARTITION BY _data_particao
AS
SELECT
  ano,
  id_municipio,
  serie,
  rede,
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
  CURRENT_DATE('America/Sao_Paulo') AS _data_particao,
  CURRENT_TIMESTAMP() AS _data_ingestao,
  'basedosdados.br_inep_avaliacao_alfabetizacao.municipio' AS _fonte
FROM `basedosdados.br_inep_avaliacao_alfabetizacao.municipio`;

CREATE OR REPLACE TABLE
  `tech-alfabetizacao-vdemarchi.bronze.uf`
PARTITION BY _data_particao
AS
SELECT
  ano,
  sigla_uf,
  serie,
  rede,
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
  CURRENT_DATE('America/Sao_Paulo') AS _data_particao,
  CURRENT_TIMESTAMP() AS _data_ingestao,
  'basedosdados.br_inep_avaliacao_alfabetizacao.uf' AS _fonte
FROM `basedosdados.br_inep_avaliacao_alfabetizacao.uf`;
