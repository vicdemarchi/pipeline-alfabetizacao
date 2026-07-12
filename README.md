# Pipeline Híbrido para Análise da Alfabetização no Brasil

Projeto desenvolvido para o **Tech Challenge – Fase 2**.

## 1. Visão geral

Este projeto implementa uma pipeline de dados no Google Cloud para integrar, tratar e analisar informações do **Indicador Criança Alfabetizada** disponibilizadas pela Base dos Dados.

A solução combina:

- processamento **batch** para os dados históricos;
- arquitetura **Medalhão** com camadas Bronze, Silver e Gold;
- validações de qualidade e integridade;
- simulação de ingestão em tempo quase real por **micro-batches**;
- monitoramento de volume, erros e latência;
- práticas de FinOps no BigQuery.

## 2. Problema de negócio

Os dados de alfabetização estão distribuídos em diferentes níveis de granularidade:

- Brasil;
- unidades federativas;
- municípios;
- microdados de alunos.

O objetivo foi criar uma base única, rastreável e confiável para:

- acompanhar resultados de alfabetização;
- comparar resultados com metas;
- identificar diferenças entre fontes;
- apoiar dashboards e análises estatísticas;
- preparar os dados para futuras aplicações de inteligência artificial.

## 3. Arquitetura

```mermaid
flowchart LR
    BD[Base dos Dados] --> BATCH[Carga batch]
    BATCH --> BR[Bronze]
    BR --> SI[Silver]
    SI --> GO[Gold]
    SI --> QA[Qualidade]
    GO --> QA

    PY[Simulador Python] --> JSONL[Eventos JSONL]
    JSONL --> BRS[Bronze Streaming]
    BRS --> SIS[Silver Streaming]
    SIS --> GOS[Gold Streaming]

    QA --> MON[Monitoramento]
    GOS --> MON
    GO --> BI[Dashboards e análises]
    GO --> IA[Modelos de IA]
```

## 4. Estrutura do repositório

```text
pipeline-alfabetizacao/
├── README.md
├── requirements.txt
├── .gitignore
├── docs/
│   ├── arquitetura.md
│   ├── checklist_entrega.md
│   ├── plano_git.md
│   └── roteiro_video.md
├── evidencias/
├── sql/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   ├── quality/
│   ├── monitoring/
│   └── streaming/
└── src/
    └── streaming/
```

## 5. Fontes de dados

Foram utilizadas as seis tabelas obrigatórias da Base dos Dados:

- `alunos`;
- `meta_alfabetizacao_brasil`;
- `meta_alfabetizacao_municipio`;
- `meta_alfabetizacao_uf`;
- `municipio`;
- `uf`.

## 6. Camada Bronze

A Bronze preserva os dados de origem e adiciona metadados técnicos:

- `_data_particao`;
- `_data_ingestao`;
- `_fonte`.

### Volumes validados

| Tabela | Registros |
|---|---:|
| alunos | 3.867.999 |
| meta_alfabetizacao_brasil | 3 |
| meta_alfabetizacao_municipio | 10.704 |
| meta_alfabetizacao_uf | 81 |
| municipio | 23.995 |
| uf | 145 |

Total batch preservado: **3.902.927 registros**.

## 7. Camada Silver

Na Silver foram aplicadas:

- padronização de tipos;
- tratamento de chaves;
- tradução de códigos documentados;
- validação estrutural;
- identificação de registros aptos para análise;
- preservação de valores ausentes da fonte como `NULL`.

### Microdados de alunos

- registros totais: **3.867.999**;
- registros aptos para análise: **3.354.661**;
- ausente ou presença não informada: **512.153**;
- caderno não preenchido ou não informado: **1.185**.

## 8. Camada Gold

Foram criadas as seguintes tabelas analíticas:

- `gold.indicador_municipio`;
- `gold.indicador_uf`;
- `gold.indicador_brasil`;
- `gold.evolucao_alfabetizacao`;
- `gold.indicador_streaming`.

### Gold municipal

- 10.951 linhas;
- 0 duplicidades;
- 5.232 comparações válidas com a meta do próprio ano;
- 2.788 municípios atingiram ou superaram a meta;
- 2.444 ficaram abaixo da meta.

### Gold estadual

- 81 linhas;
- 0 duplicidades;
- 24 comparações válidas;
- 11 resultados atingiram ou superaram a meta;
- 13 ficaram abaixo da meta.

### Gold nacional

- 3 linhas;
- 0 duplicidades;
- 2 comparações válidas;
- 1 resultado atingiu ou superou a meta;
- 1 ficou abaixo da meta;
- 1 ano não possuía meta de referência.

### Gold temporal consolidada

- 11.035 linhas;
- 11.035 chaves distintas;
- 0 duplicidades;
- 0 códigos geográficos ausentes;
- 10.951 linhas municipais;
- 81 linhas estaduais;
- 3 linhas nacionais;
- período de 2023 a 2025.

## 9. Qualidade dos dados

As regras de qualidade verificam:

- igualdade de volume entre Bronze e Silver;
- chaves obrigatórias;
- duplicidades;
- taxas fora do intervalo de 0 a 100;
- registros estruturalmente inválidos;
- integridade entre metas e resultados;
- classificação de todas as comparações válidas.

Resultado final:

- **59 regras analisadas**;
- **0 regras críticas com status `REVISAR`**;
- divergências e ausências reais da fonte registradas como informativas.

As diferenças entre tabelas de metas e resultados foram preservadas para garantir rastreabilidade.

## 10. Streaming simulado

Por limitação do BigQuery Sandbox, foi implementada uma simulação em tempo quase real por micro-batches.

Fluxo:

```text
Python
  ↓
arquivo JSONL
  ↓
Bronze de eventos
  ↓
Silver de eventos
  ↓
Gold de eventos
```

Cada evento contém:

- identificador único;
- município;
- ano;
- taxa simulada;
- data do evento;
- data de ingestão;
- origem;
- marcação explícita `dado_simulado = true`.

Resultados:

- 5 eventos processados;
- 5 IDs distintos;
- 5 municípios distintos;
- 0 eventos inválidos;
- 0 eventos identificados como reais.

Em uma arquitetura de produção, essa etapa poderia ser substituída por Pub/Sub e processamento contínuo.

## 11. Monitoramento

A tabela `quality.monitoramento_pipeline` registra:

- volume processado;
- registros com erro;
- latência média;
- latência máxima;
- status de cada componente.

Foram monitorados:

- Batch Bronze → Silver;
- qualidade final;
- Gold temporal;
- Streaming Bronze;
- Streaming Silver;
- Streaming Gold.

Todas as verificações ficaram com status **APROVADO**.

## 12. FinOps

Práticas aplicadas:

- uso do BigQuery Sandbox;
- seleção explícita de colunas;
- particionamento pela data de ingestão;
- clustering por chaves frequentemente consultadas;
- ausência de particionamento em tabelas pequenas;
- remoção de tabelas temporárias;
- acompanhamento de bytes processados;
- preferência por serviços gerenciados e arquitetura simples.

## 13. Governança e rastreabilidade

A solução mantém:

- origem dos dados;
- datas de ingestão e processamento;
- identificação de registros inválidos;
- preservação de valores ausentes;
- divergências entre fontes;
- histórico de commits;
- branches e Pull Requests no GitHub;
- evidências de execução e validação.

## 14. Aplicações futuras em IA

A camada Gold pode apoiar:

- previsão de taxas de alfabetização;
- identificação de municípios em risco;
- classificação de vulnerabilidade educacional;
- criação de clusters de municípios;
- análise de desigualdades;
- priorização de políticas públicas;
- recomendação de ações de intervenção.

## 15. Limitações

- o streaming foi simulado por micro-batches;
- não foram integradas fontes externas opcionais;
- valores ausentes não foram convertidos em zero;
- divergências entre fontes não foram apagadas;
- significados não documentados não foram inferidos;
- a solução foi implementada no BigQuery Sandbox.

## 16. Evidências

### Validação da Bronze

![Validação da Bronze](evidencias/01_validacao_bronze.png)

### Validação da Silver de alunos

![Validação da Silver](evidencias/02_validacao_silver_alunos.png)

### Validação da Gold temporal

![Validação da Gold temporal](evidencias/03_validacao_gold_temporal.png)

### Auditoria final de qualidade

![Auditoria de qualidade](evidencias/04_auditoria_qualidade.png)

### Simulação de eventos no Cloud Shell

![Streaming simulado](evidencias/05_streaming_cloud_shell.png)

### Monitoramento da pipeline

![Monitoramento](evidencias/06_monitoramento_pipeline.png)

## 17. Execução

Ordem recomendada:

1. executar os scripts em `sql/bronze`;
2. executar os scripts em `sql/silver`;
3. executar os scripts em `sql/gold`;
4. executar os scripts em `sql/quality`;
5. executar o simulador em `src/streaming`;
6. executar os scripts em `sql/streaming`;
7. executar `sql/monitoring/monitoramento_pipeline.sql`.

## 18. Tecnologias

- Google Cloud;
- BigQuery;
- Cloud Shell;
- SQL;
- Python;
- Git;
- GitHub.
