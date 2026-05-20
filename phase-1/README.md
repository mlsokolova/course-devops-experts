# Phase 1: Foundation — Docker

This folder contains Docker resources for the [QuakeWatch](https://github.com/EduardUsatchev/QuakeWatch) Flask application, per the course Phase 1 task: **Dockerfile**, **docker-compose.yml**, and this **README**.

Application source is cloned from upstream in the Docker build stage (`git clone` into `/QuakeWatch`), then copied into the final runtime image.

## Image layout

- **Multi-stage build:** dependencies are installed in a **Debian Bookworm** builder; the runtime image is **`gcr.io/distroless/python3-debian12:nonroot`** for a minimal footprint and non-root process.
- **Virtualenv:** a Python venv is created at **`/venv`** in the build stage and copied into the final image. The container **entrypoint uses `/venv/bin/python3`** .
- **`HOME` / `TMPDIR`** are set to **`/tmp`** so nothing writes under `/home/nonroot`.

### Debian / distroless version alignment

| Stage        | Image                                      | OS / Python                         |
| ------------ | ------------------------------------------ | ----------------------------------- |
| Build        | `debian:bookworm-slim`                     | Debian **12** (Bookworm), Python **3.11** from Debian packages |
| Final        | `gcr.io/distroless/python3-debian12:nonroot` | Debian **12**–based distroless, Python **3.11** |

## Run with Docker Compose

From this directory (`phase-1/`):
```bash
docker compose up --build
```
Open [http://localhost:5000](http://localhost:5000)