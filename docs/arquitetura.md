# Arquitetura da solução

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

## Decisões principais

- BigQuery como data lakehouse analítico;
- Arquitetura Medalhão;
- batch para dados históricos;
- micro-batches para simulação em tempo quase real;
- partição pela data de ingestão;
- clustering por chaves de consulta;
- preservação de valores nulos e divergências entre fontes.
