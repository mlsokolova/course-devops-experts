# Final project — QuakeWatch

Docker image and Kubernetes manifests for the QuakeWatch Flask app (namespace `final-project`).

## Files and folders

### Root

- [README.md](README.md) — project overview and file index
- [Dockerfile](Dockerfile) — builds `mlsokolova/quakewatch` from `python:3.11-slim` and `Quakewatch/`
- [docker-compose.yml](docker-compose.yml) — runs the app locally on port 5000
- [quakewatch.yaml](quakewatch.yaml) — `Deployment` and `NodePort` `Service` for the web app (probes on port 5000)
- [cronjob-quakewath-check.yaml](cronjob-quakewath-check.yaml) — `CronJob` health check via `curl` to `/graph-earthquakes`
- [components.yaml](components.yaml) — [metrics-server](https://github.com/kubernetes-sigs/metrics-server) v0.8.1 manifest with `--kubelet-insecure-tls` (for local clusters such as Docker Desktop)
- seed-data/

### `Quakewatch/`

Flask application source (vendored from [QuakeWatch](https://github.com/EduardUsatchev/QuakeWatch)).

- `app.py` — creates the Flask app, configures logging, registers routes
- `dashboard.py` — HTTP routes (`/health`, `/ping`, earthquake pages, USGS-backed APIs)
- `utils.py` — country/region settings, matplotlib graphs, USGS query helpers
- `requirements.txt` — Python package list for the image build
- `templates/` — Jinja2 HTML (`base.html`, main and graph dashboards)
- `static/` — static files (logo and assets)

### `docs/`

- [1-Docker.md](docs/1-Docker.md) — Phase 1 documentation: build, run, compose, push image tag `2.0.0`
- [2-Kubernetes.md](docs/2-Kubernetes.md) — Phase 2 documentation: create namespace, deploy app, CronJob, HPA, ConfigMap
- [install-kubernetes-cluster.pdf](docs/install-kubernetes-cluster.pdf) — Docker Desktop Kubernetes install on Windows 11

## Seed data  
Data from Kaggle dataset [All the Earthquakes Dataset : from 1990-2023](https://www.kaggle.com/datasets/alessandrolobello/the-ultimate-earthquake-dataset-from-1990-2023) in parquet format, for statistics over time period.  
[DuckDB Quack](https://duckdb.org/docs/current/quack/overview) will be used to separate data service.  
### download  seed data  
gdown should be installed with using `pip`  
```
gdown https://drive.google.com/uc?id=12iG4h8tdYXJCPwYz8EMzBScbPioq5Evv
```
### on data service  
```
import duckdb  
conn = duckdb.connect("seed-data/earthquakes.duckdb")  
conn.sql("create table earthquakes as select * from 'seed-data/Earthquakes-1990-2023.parquet'")  
duckdb.sql("force install quack from core_nightly; load quack")  
conn.sql("CALL quack_serve('quack:0.0.0.0:9494', allow_other_hostname => true);")  
```
expected output should be like this:  
```
┌────────────────────┬─────────────────────┬──────────────────────────────────┐
│     listen_uri     │     listen_url      │            auth_token            │
│      varchar       │       varchar       │             varchar              │
├────────────────────┼─────────────────────┼──────────────────────────────────┤
│ quack:0.0.0.0:9494 │ http://0.0.0.0:9494 │ 3DCA7EE39EEF5309959AF0DC07C1FA75 │
└────────────────────┴─────────────────────┴──────────────────────────────────┘

```
### on client  
```
import duckdb  
conn = duckdb.connect(":memory:")  
conn.sql("from quack_query('quack:localhost', 'select * from main.earthquakes limit 1', token='3DCA7EE39EEF5309959AF0DC07C1FA75')")  
```



