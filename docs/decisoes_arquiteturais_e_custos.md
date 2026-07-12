# Decisões arquiteturais, trade-offs e custos

## Ferramentas escolhidas

### BigQuery

O BigQuery foi escolhido como plataforma analítica central por ser totalmente gerenciado, sem servidor e adequado a consultas SQL sobre grandes volumes. A separação entre armazenamento e processamento reduz a necessidade de administrar infraestrutura.

### Python e Cloud Shell

O simulador utiliza somente a biblioteca padrão do Python. O Cloud Shell oferece as ferramentas `gcloud`, `bq` e Python no mesmo ambiente, reduzindo configuração local e risco de incompatibilidade.

### Git e GitHub

O repositório registra scripts, documentação, evidências, branches, commits e Pull Requests, fornecendo rastreabilidade para a evolução do projeto.

## Trade-off: batch × streaming

| Critério | Batch histórico | Streaming em produção | Micro-batch do protótipo |
|---|---|---|---|
| Latência | Alta | Baixa | Intermediária |
| Complexidade | Baixa | Alta | Baixa |
| Reprocessamento | Simples | Mais complexo | Simples |
| Custo operacional | Menor | Maior | Muito baixo |
| Uso no projeto | Seis fontes históricas | Arquitetura futura | Demonstração executada |

O batch atende melhor à natureza periódica dos dados oficiais. O micro-batch demonstra o fluxo de eventos sem declarar falsamente a implementação de streaming nativo.

## Trade-off: data lake × data warehouse

O projeto usa o BigQuery como plataforma central. A Bronze preserva dados e metadados de origem, enquanto Silver e Gold organizam o consumo analítico.

Vantagens da abordagem:

- menor complexidade;
- uma única linguagem de consulta;
- integração simples entre as camadas;
- operação sem servidores.

Limitação:

- não existe um data lake separado para guardar arquivos brutos imutáveis.

Em produção de grande escala, o Cloud Storage poderia ser usado para a zona bruta e o BigQuery para Silver, Gold e consumo analítico.

## Trade-off: custo × desempenho

- Particionamento foi aplicado onde havia volume e filtro temporal.
- Clustering foi usado nas chaves de consulta mais prováveis.
- Tabelas pequenas não foram particionadas.
- Consultas evitam `SELECT *` quando a seleção explícita é suficiente.
- Serviços gerenciados reduzem manutenção, mas transferem o custo para o consumo.

## Estimativa de custo

### Protótipo

- BigQuery Sandbox sem faturamento habilitado.
- Custo financeiro observado: **US$ 0**.

### Produção de baixo volume

Hipóteses:

- até 10 GiB de armazenamento lógico;
- até 1 TiB de consultas por mês;
- 1 GiB/mês de eventos;
- Pub/Sub com assinatura direta para BigQuery;
- sem Dataflow contínuo.

| Componente | Estimativa mensal |
|---|---:|
| BigQuery: armazenamento | US$ 0 dentro da franquia |
| BigQuery: consultas | US$ 0 dentro da franquia |
| Pub/Sub: publicação básica | US$ 0 abaixo de 10 GiB |
| Pub/Sub → BigQuery | aproximadamente US$ 0,05 para 1 GiB |
| Total de referência | aproximadamente US$ 0,05 |

Cálculo da assinatura para BigQuery: `US$ 50/TiB × 1 GiB ÷ 1.024 ≈ US$ 0,049`.

Dataflow não foi incluído. Caso seja necessário manter processamento contínuo com janelas ou transformações complexas, vCPU, memória, disco e Streaming Engine devem ser estimados separadamente.

## Fontes oficiais consultadas

- BigQuery Sandbox: https://cloud.google.com/bigquery/docs/sandbox
- Preços do BigQuery: https://cloud.google.com/bigquery/pricing
- Preços do Pub/Sub: https://cloud.google.com/pubsub/pricing
- Preços do Dataflow: https://cloud.google.com/dataflow/pricing
- Calculadora do Google Cloud: https://cloud.google.com/products/calculator
