Simple Elasticsearch 1.7 k8s example 

To start the pod and services execute the following commands

```
kubectl create -f service-account.yaml
kubectl create -f es-svc.yaml
kubectl create -f es-rc.yaml
kubectl create -f rbac.yaml
```

to destroy the pod and services execute the following commands

```
kubectl delete -f rbac.yaml
kubectl delete -f es-rc.yaml
kubectl delete -f es-svc.yaml
kubectl delete -f service-account.yaml
```

to get the status of the pod and services execute the following commands
```
kubectl get pods
kubectl get service elasticsearch17
```

to allow to access from outside of k8s cluster execute

```
kubectl create -f es-ingress.yaml
```