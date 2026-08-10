#!/usr/bin/env sh
# Stops ProctorEye. Your data is untouched — `stop`, not `down` — ./run.sh
# starts it again instantly.
set -eu
cd "$(dirname "$0")/.."
docker compose stop
echo "Stopped. Run ./run.sh any time to start it again."
