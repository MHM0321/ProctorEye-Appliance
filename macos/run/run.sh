#!/usr/bin/env sh
# Everyday start — no setup, just starts what ../install/install.sh already
# configured, then opens 3 separate Terminal windows (api, worker,
# dashboard) that each tail ONE service's logs. Closing a log window only
# stops watching — the containers run detached regardless. Use ./stop.sh
# to actually stop the app.
set -eu
cd "$(dirname "$0")/.."
COMPOSE_DIR="$(pwd)"

if [ ! -f .env ]; then
  echo "No .env found — run ../install/install.sh first (one-time setup)."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker doesn't seem to be running. Start it and try again."
  exit 1
fi

echo "==> Starting..."
docker compose up -d

echo "==> Opening log windows for api, worker, and dashboard..."
for svc in api worker dashboard; do
  osascript -e "tell application \"Terminal\" to do script \"cd '$COMPOSE_DIR' && echo 'Logs for: $svc (closing this window only stops watching)' && docker compose logs -f --tail 100 $svc\""
done

DASH_PORT=$(grep '^DASHBOARD_PORT=' .env | cut -d= -f2)
DASH_PORT=${DASH_PORT:-8080}
echo ""
echo "Running. Open http://localhost:$DASH_PORT"
echo "3 log windows just opened — closing them is fine, they're only viewers."
echo "To stop ProctorEye itself, run ./stop.sh in this same folder."
