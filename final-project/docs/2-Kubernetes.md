# Phase 2: Orchestration — Kubernetes Basics & Advanced

This phase deploys the customized QuakeWatch stack on Kubernetes: the Flask web app (`quakewatch`) and the DuckDB Quack server (`duckdb`). The web app queries USGS for live graphs and uses `quakestats.py` to fetch historical statistics from DuckDB over the Quack protocol.

Image: `mlsokolova/quakewatch:3.0.0` (namespace `final-project`).

## Set up the cluster

```bash
kubectl create ns final-project
kubectl config set-context --current --namespace=final-project
```

## Run the dockerized web app as a pod (optional smoke test)

```bash
docker pull mlsokolova/quakewatch:3.0.0
kubectl run quakewatch --image=mlsokolova/quakewatch:3.0.0
```

This runs only the Flask container without DuckDB. Pages that depend on `QuakeStats` (for example `/graph-earthquakes`) need the full stack below.

## Deploy configuration and storage

Apply shared config before the workloads:

```bash
kubectl apply -f configmap-quakewatch.yaml
kubectl apply -f secret-quakewatch.yaml
kubectl apply -f pv-duckdb.yaml
```

| Manifest | Kind | Purpose |
| -------- | ---- | ------- |
| `configmap-quakewatch.yaml` | ConfigMap | `QUAKEWATCH__LOG_PATH`, `MPLCONFIGDIR`, `QUACK__HOST`, `QUACK__PORT`, `DUCKDB__PATH` |
| `secret-quakewatch.yaml` | Secret | `QUACK__TOKEN` (shared by `quakewatch` and `duckdb`) |
| `pv-duckdb.yaml` | PV + PVC | Persistent storage for `/data/earthquakes.duckdb` |

The PVC `duckdb-data` uses a `hostPath` volume at `/data/duckdb` on the node. On Docker Desktop you may need to copy `seed-data/` there, or adjust the `hostPath` in `pv-duckdb.yaml` to point at your local folder.

## Deploy DuckDB

```bash
kubectl apply -f duckdb.yaml
```

The `duckdb` Deployment includes:

- **init container** `seed-data` — runs `seed_data.py`; downloads the parquet file and creates the `earthquakes` table if missing
- **main container** — runs `duckdb-quack-service.py`; serves Quack on port `9494`

Wait until the pod is ready:

```bash
kubectl get pods -l app=duckdb
kubectl logs -l app=duckdb -c seed-data
```

## Deploy QuakeWatch

```bash
kubectl apply -f quakewatch.yaml
```

The `quakewatch` Deployment includes:

- **init container** `wait-for-duckdb` — blocks until the `duckdb` Service is reachable on the Quack port
- **main container** — runs `app.py`; env vars for logging, matplotlib, and Quack connectivity come from the ConfigMap and Secret

Verify both services:

```bash
kubectl get pods
kubectl get svc
```

Open the app via the `quakewatch` NodePort or port-forward:

```bash
kubectl port-forward svc/quakewatch 5000:5000
```

Then visit [http://127.0.0.1:5000/graph-earthquakes](http://127.0.0.1:5000/graph-earthquakes).

## Run the CronJob

```bash
kubectl apply -f cronjob-quakewath-check.yaml
```

Periodic health check via `curl` to `/graph-earthquakes` (exercises both Flask and DuckDB).

## Install Metrics Server

1. Download the upstream manifest (optional — a patched copy is already in the repo):

   ```bash
   wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.8.1/components.yaml
   ```

2. For local clusters (Docker Desktop), add `--kubelet-insecure-tls` to the container `args` section. The root [`components.yaml`](../components.yaml) already includes this flag.

3. Apply:

   ```bash
   kubectl apply -f components.yaml
   ```

4. Wait a minute, then check:

   ```bash
   kubectl top node
   ```

   Expected output:

   ```
   NAME                    CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
   desktop-control-plane   128m         0%       783Mi           5%
   desktop-worker          31m          0%       607Mi           3%
   ```

## Apply Horizontal Pod Autoscaler

```bash
kubectl apply -f hpa-quakewatch.yaml
```

## Test Horizontal Pod Autoscaler

1. Run the Apache HTTP server benchmarking tool:

   ```bash
   kubectl run quakewatch-benchmark -it --rm --restart=Never --image=httpd:2.4 -- ab -n 100 -c 20 -s 60 http://quakewatch:5000/graph-earthquakes
   ```

   (100 requests to the heaviest page, 20 in parallel.)

2. Watch scaling events:

   ```bash
   kubectl get events
   kubectl get hpa
   ```

## Manifest overview

| File | Resources |
| ---- | --------- |
| `configmap-quakewatch.yaml` | ConfigMap |
| `secret-quakewatch.yaml` | Secret |
| `pv-duckdb.yaml` | PersistentVolume, PersistentVolumeClaim |
| `duckdb.yaml` | Deployment, Service (`duckdb`) |
| `quakewatch.yaml` | Deployment, Service (`quakewatch`) |
| `cronjob-quakewath-check.yaml` | CronJob |
| `hpa-quakewatch.yaml` | HorizontalPodAutoscaler |
| `components.yaml` | metrics-server (cluster-wide) |

## Teardown

Delete resources in reverse order of deployment:

```bash
kubectl delete -f hpa-quakewatch.yaml
kubectl delete -f cronjob-quakewath-check.yaml
kubectl delete -f quakewatch.yaml
kubectl delete -f duckdb.yaml
kubectl delete -f pv-duckdb.yaml
kubectl delete -f secret-quakewatch.yaml
kubectl delete -f configmap-quakewatch.yaml
```
