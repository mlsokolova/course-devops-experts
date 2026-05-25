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

## Install Metrics Server
1. `wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.8.1/components.yaml`
2. add `--kubelet-insecure-tls` arg into args section for containers  
`componets.yaml` v0.8.1 with `--kubelet-insecure-tls` is in the root folder
3.`kubctl apply -f componets.yaml`
4. wait
