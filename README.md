# atlas-local

```
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo update
```


```
helm install infrastructure ./infrastructure -n atlas-infrastructure --create-namespace
```


```
helm install kafka confluentinc/cp-helm-charts -n kafka -f ./kafka/values.yaml --create-namespace
```

```
helm install observation-crud ./observation-crud -n atlas-observation-crud-service --create-namespace
```