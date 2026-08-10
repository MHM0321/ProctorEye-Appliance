#!/usr/bin/env sh
# Everyday start — no setup, just starts what ../install/install.sh already
# configured, then opens 3 separate terminal windows (api, worker,
# dashboard) that each tail ONE service's logs. Closing a log window only
# stops watching — the containers run detached regardless. Use ./stop.sh
# to actually stop the app.
#
# No single terminal emulator is universal on Linux — this tries the
# common ones in order. If none are found, it prints the commands to run
# manually instead of failing silently.
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

open_log_window() {
  svc="$1"
  cmd="cd '$COMPOSE_DIR' && echo 'Logs for: $svc (closing this window only stops watching)' && docker compose logs -f --tail 100 $svc; exec sh"
  if command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal --title="ProctorEye logs: $svc" -- sh -c "$cmd"
  elif command -v konsole >/dev/null 2>&1; then
    konsole --title "ProctorEye logs: $svc" -e sh -c "$cmd"
  elif command -v xterm >/dev/null 2>&1; then
    xterm -T "ProctorEye logs: $svc" -e sh -c "$cmd" &
  else
    echo "No terminal emulator found for $svc — run this manually in your own terminal:"
    echo "  docker compose logs -f $svc"
  fi
}

echo "==> Opening log windows for api, worker, and dashboard..."
open_log_window api
open_log_window worker
open_log_window dashboard

DASH_PORT=$(grep '^DASHBOARD_PORT=' .env | cut -d= -f2)
DASH_PORT=${DASH_PORT:-8080}
echo ""
echo "Running. Open http://localhost:$DASH_PORT"
echo "To stop ProctorEye itself, run ./stop.sh in this same folder."
