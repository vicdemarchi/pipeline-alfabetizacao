# Roteiro executivo — até 5 minutos

## 1. Problema de negócio — 40 segundos

A alfabetização no 2º ano é um indicador central para políticas públicas. O desafio foi integrar dados nacionais, estaduais, municipais e microdados de alunos em uma arquitetura confiável e escalável.

## 2. Arquitetura — 1 minuto

A solução foi implementada no Google Cloud com BigQuery e Arquitetura Medalhão:

- Bronze: dados brutos;
- Silver: dados tratados e validados;
- Gold: dados analíticos.

A pipeline combina batch e uma simulação de streaming por micro-batches.

## 3. Qualidade — 50 segundos

Foram aplicadas regras de:

- volume;
- chaves;
- duplicidade;
- valores ausentes;
- taxas fora de intervalo;
- integridade entre metas e resultados.

Nenhuma regra crítica ficou em revisão.

## 4. Resultados — 1 minuto

Principais números:

- 3.902.927 registros preservados entre Bronze e Silver;
- 11.035 linhas na Gold temporal;
- nenhuma duplicidade nas chaves analíticas;
- 59 regras de qualidade;
- 5 eventos simulados processados no fluxo de streaming.

## 5. FinOps e monitoramento — 40 segundos

A solução usa:

- BigQuery Sandbox;
- seleção explícita de colunas;
- partição por data de ingestão;
- clustering;
- remoção de tabelas temporárias;
- monitoramento de volume, erro e latência.

## 6. Potencial de IA — 40 segundos

A camada Gold pode apoiar:

- previsão de alfabetização;
- identificação de municípios em risco;
- análise de desigualdades;
- clusters de vulnerabilidade;
- priorização de políticas públicas.

## Encerramento — 10 segundos

A solução entrega uma base confiável, rastreável e preparada para análises, dashboards e futuras aplicações de IA.
