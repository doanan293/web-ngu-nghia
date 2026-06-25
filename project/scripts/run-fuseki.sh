#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

FUSEKI_URL="${FUSEKI_URL:-http://localhost:3030}"
DATASET="${DATASET:-dataset}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin}"

SCHEMA_FILE="luat-doanh-nghiep-schema.ttl"
DATA_FILE="luat-doanh-nghiep-data.ttl"

for file in docker-compose.yml "$SCHEMA_FILE" "$DATA_FILE"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required file: $file" >&2
    exit 1
  fi
done

echo "Starting Fuseki..."
docker compose up -d

echo "Waiting for Fuseki at ${FUSEKI_URL}/${DATASET}/query..."
ready_query='ASK { ?s ?p ?o }'

for attempt in $(seq 1 60); do
  if curl -fsS -G "${FUSEKI_URL}/${DATASET}/query" \
    --data-urlencode "query=${ready_query}" >/dev/null 2>&1; then
    break
  fi

  if [[ "$attempt" -eq 60 ]]; then
    echo "Fuseki did not become ready after 60 seconds." >&2
    docker compose logs --tail=80 fuseki >&2 || true
    exit 1
  fi

  sleep 1
done

load_turtle() {
  local file="$1"

  echo "Loading ${file}..."
  curl -fsS -u "${ADMIN_USER}:${ADMIN_PASSWORD}" -X POST \
    -H "Content-Type: text/turtle; charset=utf-8" \
    --data-binary "@${file}" \
    "${FUSEKI_URL}/${DATASET}/data" >/dev/null
}

load_turtle "$SCHEMA_FILE"
load_turtle "$DATA_FILE"

echo "Fuseki is ready and data has been loaded:"
echo "${FUSEKI_URL}/${DATASET}"
