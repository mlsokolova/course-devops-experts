# Phase 2: Orchestration — Kubernetes Basics & Advanced

## Files

- [README.md](README.md): this file
- `Install-kubernetes-cluster.pdf`: screenshots of the Docker Desktop installation process on Windows 11
- `quakewatch.yaml`: Kubernetes resources for the QuakeWatch web app
- `cronjob-quakewath-check.yaml`: Kubernetes resource definition for the CronJob

## Set up the cluster

```bash
kubectl create ns final-project
kubectl config set-context --current --namespace=final-project
```

## Run the dockerized web app as a pod

```bash
docker pull mlsokolova/quakewatch:devops-experts-phase1
kubectl run quakewatch --image=mlsokolova/quakewatch:devops-experts-phase1
```

## Deploy the QuakeWatch web app

```bash
kubectl apply -f quakewatch.yaml
```

## Run the CronJob

```bash
kubectl apply -f cronjob-quakewath-check.yaml
```

## TODO

- Change the QuakeWatch app so demo paths are less “demo”; the `/health` path should return real local checks
- Add a check for USGS accessibility
