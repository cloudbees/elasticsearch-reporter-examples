Simple Elasticsearch k8s example see https://github.com/pires/kubernetes-elasticsearch-cluster

To start the pod and services execute the following command

```
kubectl create -f elasticsearch.yaml
```

to destroy the pod and services execute the following command

```
kubectl delete -f elasticsearch.yaml
```

to get the status of the pod and services execute the following commands
```
kubectl get pods
kubectl get service elasticsearch
```

to allow to access from outside of k8s cluster execute

```
kubectl create -f es-ingress.yaml
```

to scale the pods execute the following command

```
kubectl scale --replicas=3 rc es
```