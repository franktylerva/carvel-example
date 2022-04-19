# atlas-local

```
helm install nginx-ingress bitnami/nginx-ingress-controller
```

```
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo update
```

```
kubectl create configmap scripts -n atlas-observation-crud-service --from-file=./sql 
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

```
kubectl exec -it observation-crud-postgresql-0 -n atlas-observation-crud-service -- sh -c "psql -U dbuser -d obsdb -a -f /scripts/create-schema.sql"
```

```
kubectl exec -it observation-crud-postgresql-0 -n atlas-observation-crud-service -- sh -c "psql -U dbuser -d obsdb -a -f /scripts/drop-schema.sql"
```