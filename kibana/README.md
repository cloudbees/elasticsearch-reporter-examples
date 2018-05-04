Simple Kibana k8s example see https://github.com/pires/kubernetes-elasticsearch-cluster
kibana credentials - admin:1PelasticW2 , you can use htpasswd to create a new file 
with different user and password

To start the pod and services execute the following command

```
kubectl create secret generic kibana-basic-auth --from-file=auth
kubectl create -f kibana.yaml
```

to destroy the pod and services execute the following command

```
kubectl delete secret kibana-basic-auth
kubectl delete -f kibana.yaml
```

to get the status of the pod and services execute the following commands
```
kubectl get pods
kubectl get service kibana
```

KibanaExamples-5x.json file contains some dashboards examples.