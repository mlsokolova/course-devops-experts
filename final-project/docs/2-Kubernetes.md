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
5. check
`kubectl top node` should return something like this:
```
NAME                    CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
desktop-control-plane   128m         0%       783Mi           5%
desktop-worker          31m          0%       607Mi           3%
```
## Apply Horizontal Pod Autoscaler
`kubectl apply -f hpa-quakewatch.yaml`

## Test Horizontal Pod Autoscaler
1. Run Apache HTTP server benchmarking tool
`kubectl run quakewatch-benchmark -it --rm --restart=Never --image=httpd:2.4 -- ab -n 100 -c 20 -s 60 http://quakewatch:5000/graph-earthquakes`
(100 request to the heavies page of the QuakeWatch web app, 20 requests in parallel )
2. watch events
`kubectl get events`
