# ProctorEye — appliance

Everything runs on your own server. Nothing here needs source code or a
GitHub account — just Docker.

**Pick your OS folder** (`windows/`, `macos/`, or `linux/`) — each is
self-contained (its own `docker-compose.yml` and `.env.example`), so you
only ever need the one folder for your platform.

Inside each OS folder:
- **`install/`** — run once, first time only. Checks Docker, creates `.env`
  and generates real secrets, pulls the images. Does **not** start anything.
- **`run/`** — your everyday folder. `run` starts ProctorEye and opens
  **3 separate windows**, one each for the api, worker, and dashboard logs.
  `stop` stops it again.

## First time

1. **Prerequisite:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine on Linux), installed and running.
2. In your OS folder, copy `.env.example` to `.env`.
3. Edit `.env`: set `IMAGE_REGISTRY` to the value ProctorEye gave you, and `PUBLIC_API_URL` to this machine's real address (a domain or IP — not `localhost`, unless you're only testing on this same machine).
4. Run the installer:
   - **Windows**: double-click `windows\install\install.bat`
   - **Mac**: `./macos/install/install.sh`
   - **Linux**: `./linux/install/install.sh`
5. When it finishes, run the starter:
   - **Windows**: double-click `windows\run\run.bat`
   - **Mac**: `./macos/run/run.sh`
   - **Linux**: `./linux/run/run.sh`

That opens 3 log windows and prints the dashboard URL — open it, and you'll
land on a one-time "create your account" screen.

## Everyday use

Just `run` (`run.bat` / `./run.sh`) — skips all setup, starts faster.

The 3 log windows it opens are just viewers — closing any (or all) of them
does **not** stop ProctorEye, the containers keep running in the
background regardless. To actually stop it, use **`stop`** (`stop.bat` /
`./stop.sh`) in the same `run/` folder. Your data isn't touched — `run`
again any time to pick back up instantly.

## CORS — read this before your evaluative site stops working

`CORS_ALLOWED_ORIGINS` in `.env` must list **every origin that calls the API directly from a browser** — that's both your exam site's own domain *and* wherever this dashboard ends up served from. Missing the second one is the most common first-run mistake; it shows up as a "blocked by CORS policy" error in the browser console when logging into the dashboard itself.

## License

Works fully without one — you'll just see a small "unlicensed" mark in the dashboard and can't customize the login screen's branding. Drop a `license.jwt` file (ProctorEye will send you one) next to your OS folder's `docker-compose.yml`, then restart via `stop` then `run`.

## Updating

From your OS folder:
```
docker compose pull
```
then `stop` and `run` again. Pulls whatever's newest at `IMAGE_TAG` (`latest` by default). Your data isn't touched.

## Troubleshooting

| Symptom | Fix |
|---|---|
| CORS error logging into the dashboard | Add the dashboard's own address to `CORS_ALLOWED_ORIGINS` — see above |
| Blank dashboard / can't reach API | Check `PUBLIC_API_URL` is this machine's real, browser-reachable address |
| "set IMAGE_REGISTRY in .env" | You haven't filled in the value ProctorEye gave you yet |
| `run` fails immediately | Read the error in that window before it closes (it now pauses on failure) — often means it's already running; try `stop` first |
| Worker container keeps restarting | Check its log window, or `docker compose logs worker`, and send that to ProctorEye support |
