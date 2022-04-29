# atlas-local
Both the kapp and Helm are required.  Install these tools using brew.
```
brew install helm

brew tap vmware-tanzu/carvel
brew install kapp
brew install ytt
```

This project uses Helm Charts from Confluent and Bitnami.  Before running any of these scripts you'll need to add these chart repositories:
```
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Optionally, you can deploy Prometheus to monitor the cluster.
```
kapp deploy -a prometheus -f <(helm template prometheus bitnami/kube-prometheus)
```

Deploy the suite of applications:
```
./deploy
```

Undeploy the suite of applications:
```
./undeploy.sh
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