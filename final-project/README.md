# Final project — QuakeWatch

Docker image and Kubernetes manifests for the QuakeWatch Flask app (namespace `final-project`).

## Files and folders

### Root

- [README.md](README.md) — project overview and file index
- [Dockerfile](Dockerfile) — builds `mlsokolova/quakewatch` from `python:3.11-slim` and `Quakewatch/`
- [docker-compose.yml](docker-compose.yml) — runs the app locally on port 5000
- [quakewatch.yaml](quakewatch.yaml) — `Deployment` and `NodePort` `Service` for the web app (probes on port 5000)
- [cronjob-quakewath-check.yaml](cronjob-quakewath-check.yaml) — `CronJob` health check via `curl` to `/graph-earthquakes`
- [components.yaml](components.yaml) — [metrics-server](https://github.com/kubernetes-sigs/metrics-server) v0.8.1 manifest with `--kubelet-insecure-tls` (for local clusters such as Docker Desktop);

### `Quakewatch/`

Flask application source (vendored from [QuakeWatch](https://github.com/EduardUsatchev/QuakeWatch)).

- `app.py` — creates the Flask app, configures logging, registers routes
- `dashboard.py` — HTTP routes (`/health`, `/ping`, earthquake pages, USGS-backed APIs)
- `utils.py` — country/region settings, matplotlib graphs, USGS query helpers
- `requirements.txt` — Python package list for the image build
- `templates/` — Jinja2 HTML (`base.html`, main and graph dashboards)
- `static/` — static files (logo and assets)

### `docs/`

- [1-Docker.md](docs/1-Docker.md) — Phase 1 documentation: build, run, compose, push image tag `1.0.0`
- [2-Kubernetes.md](docs/2-Kubernetes.md) — Phase 2 documentation: create namespace, deploy app and CronJob
- [install-kubernetes-cluster.pdf](docs/install-kubernetes-cluster.pdf) — Docker Desktop Kubernetes install on Windows 11
