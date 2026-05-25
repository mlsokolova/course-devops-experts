# Phase 2: Orchestration — Kubernetes Basics & Advanced

## Set up the cluster

```bash
kubectl create ns final-project
kubectl config set-context --current --namespace=final-project
```

## Run the dockerized web app as a pod

```bash
docker pull mlsokolova/quakewatch:1.0.0
kubectl run quakewatch --image=mlsokolova/quakewatch:1.0.0
```

## Deploy the QuakeWatch web app

```bash
kubectl apply -f quakewatch.yaml
```

## Run the CronJob

```bash
kubectl apply -f cronjob-quakewath-check.yaml
```

