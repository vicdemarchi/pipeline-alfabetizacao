#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-tech-alfabetizacao-vdemarchi}"
LOCATION="${LOCATION:-US}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Configurando projeto: $PROJECT_ID"
gcloud config set project "$PROJECT_ID" >/dev/null

echo "Selecionando cinco municípios existentes..."
bq query \
  --location="$LOCATION" \
  --quiet \
  --use_legacy_sql=false \
  --format=csv \
  "SELECT DISTINCT id_municipio
   FROM \`$PROJECT_ID.gold.indicador_municipio\`
   WHERE id_municipio IS NOT NULL
   ORDER BY id_municipio
   LIMIT 5" \
  | tail -n +2 > municipios.txt

echo "Gerando eventos simulados..."
python3 gerar_eventos.py

echo "Carregando eventos na Bronze..."
bq --location="$LOCATION" load \
  --source_format=NEWLINE_DELIMITED_JSON \
  --noreplace \
  "$PROJECT_ID:bronze.eventos_streaming" \
  eventos_streaming.jsonl

echo "Validando a carga..."
bq query \
  --location="$LOCATION" \
  --quiet \
  --use_legacy_sql=false \
  "SELECT
     COUNT(*) AS total_eventos,
     COUNT(DISTINCT event_id) AS eventos_distintos,
     COUNTIF(dado_simulado IS FALSE) AS eventos_nao_simulados,
     MIN(data_evento) AS primeiro_evento,
     MAX(data_evento) AS ultimo_evento
   FROM \`$PROJECT_ID.bronze.eventos_streaming\`"

echo "Micro-batch concluído."
