# ProctorEye Appliance

Run ProctorEye on infrastructure you control. The appliance packages the dashboard, API, worker, MongoDB, and Redis as a Docker Compose stack for Windows, macOS, and Linux.

> ProctorEye is a student-built project. Test it with non-sensitive data before production use, review the configuration, and keep regular backups.

## Choose a download

Use the latest [GitHub Release](https://github.com/MHM0321/ProctorEye-Appliance/releases/latest) and download the archive for your operating system.

| Platform | Download | Start command |
|---|---|---|
| Windows | `proctoreye-appliance-windows-*.zip` | Double-click `install\install.bat`, then `run\run.bat` |
| macOS | `proctoreye-appliance-macos-*.zip` | `./install/install.sh`, then `./run/run.sh` |
| Linux | `proctoreye-appliance-linux-*.zip` | `./install/install.sh`, then `./run/run.sh` |

Each release also includes `SHA256SUMS.txt` so you can verify the archive before installing it.

## What stays on your infrastructure

The self-hosted appliance stores candidate records, images, screen captures, violations, and app-usage data in its own Docker volumes. It does not send that monitoring data to the hosted ProctorEye service.

A small license check-in may send the appliance license ID, a timestamp, and the source network address. It does not include candidate identities, images, screen captures, or violation data. See the [privacy notice](https://d31tj7rjyrvlh5.cloudfront.net/privacy) for the complete description.

## Requirements

- Docker Desktop on Windows or macOS, or Docker Engine with Docker Compose v2 on Linux
- At least 4 GB of free memory for a small installation
- A browser-reachable IP address or domain for devices that use the dashboard or SDK
- HTTPS before handling real candidate data

## Install

1. Extract the archive for your operating system.
2. Copy `.env.example` to `.env`.
3. Set `IMAGE_REGISTRY` to the registry supplied with your ProctorEye build.
4. Set `PUBLIC_API_URL` to the API address browsers can reach. Do not use `localhost` unless every browser runs on the same machine.
5. Run the installer once.
6. Run the starter and open the printed dashboard URL.
7. Create the first administrator account in the one-time setup screen.

The installer checks Docker, generates local secrets, and pulls container images. It does not start monitoring services until you run the starter.

## Everyday operation

From your platform folder:

- `run/run.bat` or `./run/run.sh` starts ProctorEye.
- `run/stop.bat` or `./run/stop.sh` stops it.
- Closing a log window does not stop the containers.
- Docker volumes keep the database and uploaded evidence between restarts.

## Configure browser access

### HTTPS for other devices

Browsers allow camera and screen capture on `localhost`, but require HTTPS
when a candidate connects from another device. The appliance includes an
optional Caddy service for this purpose.

Set these values in `.env`:

```text
COMPOSE_PROFILES=tls
DOMAIN=proctoreye.example.edu
TLS_MODE=letsencrypt
TRUST_PROXY=true
```

Use `letsencrypt` for a public domain with ports 80 and 443 reachable,
`custom-cert` when your organization supplies a certificate, or `internal`
for a closed network whose devices can trust Caddy's local certificate. Read
the matching file under `caddy/` before starting. Then change
`PUBLIC_API_URL` and the relevant CORS origin to the final HTTPS address.

Leave `TRUST_PROXY=false` when Caddy or another trusted reverse proxy is not
actually running.

### CORS origins

`CORS_ALLOWED_ORIGINS` must contain every browser origin that calls the API directly. This normally includes both:

- the dashboard origin;
- every exam or assessment site embedding the browser SDK.

A missing dashboard origin usually appears as a browser console error saying the request was blocked by CORS policy.

## Add a license

The appliance runs without a license, with an unlicensed indicator and restricted licensed features such as white-label branding.

To install a license:

1. Place the supplied `license.jwt` beside the platform's `docker-compose.yml`.
2. Stop the appliance.
3. Start it again.

## Update safely

1. Back up the Docker volumes or host storage.
2. Read the release notes for breaking changes.
3. Set `IMAGE_TAG` to the release you want, or keep `latest`.
4. Run `docker compose pull`.
5. Stop and restart the appliance.

Updating containers does not intentionally delete Docker volumes.

## Verify a release

Windows PowerShell:

```powershell
Get-FileHash .\proctoreye-appliance-windows-vX.Y.Z.zip -Algorithm SHA256
```

Linux or macOS:

```bash
sha256sum proctoreye-appliance-linux-vX.Y.Z.zip
```

Compare the result with `SHA256SUMS.txt` from the same GitHub release.

## Troubleshooting

| Problem | Check |
|---|---|
| Dashboard login is blocked by CORS | Add the dashboard and integrating site origins to `CORS_ALLOWED_ORIGINS` |
| Dashboard is blank or cannot reach the API | Confirm `PUBLIC_API_URL` is browser-reachable |
| Installer says `IMAGE_REGISTRY` is missing | Fill it in inside `.env` |
| Starter exits immediately | Read the terminal error and run the stop script before retrying |
| Worker keeps restarting | Run `docker compose logs worker` |
| License still appears inactive | Confirm the file is named `license.jwt` and restart the API |

For private security reports, follow [SECURITY.md](SECURITY.md). For setup questions, open a GitHub issue without attaching secrets, license files, candidate data, or screenshots containing personal information.
