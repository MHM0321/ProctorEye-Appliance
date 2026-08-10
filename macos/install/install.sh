#!/usr/bin/env sh
# ProctorEye appliance — FIRST-TIME setup only. Safe to re-run. When this
# finishes, go to ../run and run ./run.sh to actually start the app.
set -eu
cd "$(dirname "$0")/.."

if ! docker info >/dev/null 2>&1; then
  echo "Docker doesn't seem to be installed or running."
  echo "Install it from https://www.docker.com/products/docker-desktop/ then run this again."
  exit 1
fi

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

# Must exist as a FILE before the first `docker compose up` — Docker
# silently creates a missing bind-mount source as a DIRECTORY instead.
if [ ! -f license.jwt ]; then
  touch license.jwt
  echo "Created empty license.jwt placeholder (drop a real one here any time)"
fi

random_hex() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 32
  else
    head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n'
  fi
}

fill_if_blank() {
  key="$1"
  if grep -qE "^${key}=\s*$" .env; then
    value="$(random_hex)"
    awk -v k="$key" -v v="$value" -F= 'BEGIN{OFS="="} $1==k{$2=v} 1' .env > .env.tmp
    mv .env.tmp .env
    echo "Set $key"
  fi
}
fill_if_blank JWT_SECRET
fill_if_blank INTERNAL_API_SECRET

if grep -q "^IMAGE_REGISTRY=ghcr.io/change-me\s*$" .env || grep -q "^IMAGE_REGISTRY=\s*$" .env; then
  echo ""
  echo "IMAGE_REGISTRY in .env is still the placeholder — set it to the value"
  echo "ProctorEye gave you, then run this installer again."
  exit 1
fi

echo "Pulling images (first run only downloads anything new)..."
docker compose pull

echo ""
echo "Setup complete."
echo "Next: cd ../run && ./run.sh to start ProctorEye."
