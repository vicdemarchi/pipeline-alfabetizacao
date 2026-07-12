# Simulação de streaming por micro-batches

## Objetivo

Gerar cinco eventos fictícios de atualização de taxa de alfabetização, carregar os eventos na tabela Bronze e validar a carga.

Todos os eventos são marcados como `dado_simulado = true`.

## Pré-requisitos

- Google Cloud Shell;
- projeto com as tabelas batch já criadas;
- `bronze.eventos_streaming` criada por `sql/streaming/create_streaming_tables.sql`;
- permissão para consultar e carregar dados no BigQuery.

## Execução automática

Na raiz do repositório:

```bash
chmod +x src/streaming/executar_microbatch.sh
./src/streaming/executar_microbatch.sh
```

Variáveis opcionais:

```bash
PROJECT_ID=outro-projeto LOCATION=US ./src/streaming/executar_microbatch.sh
```

## O que o script faz

1. configura o projeto;
2. seleciona cinco municípios da Gold municipal;
3. salva os códigos em `municipios.txt`;
4. executa `gerar_eventos.py`;
5. cria `eventos_streaming.jsonl`;
6. anexa o arquivo à tabela Bronze;
7. valida volume, IDs e marcação de dados simulados.

## Atualização de Silver e Gold

Depois da carga, execute novamente:

```text
sql/streaming/create_streaming_tables.sql
```

O script SQL deduplica os eventos na Silver, valida os campos e mantém na Gold o evento mais recente de cada município.

## Limitação declarada

O fluxo é uma simulação de tempo quase real por micro-batches. Ele não é apresentado como streaming nativo. Em produção, Pub/Sub e, quando necessário, Dataflow podem substituir essa etapa.
