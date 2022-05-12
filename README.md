# atlas-local
This repository is used for setting up Atlas applications in a local development environment for demonstration and testing purposes.  Several tools are used from the Carvel project to demonstrate overlays (ytt) and ordered deployments (kapp).  This project also demonstrates how these tools work with other deployment technologies such as Helm, kustomize, and plain old k8s yaml files.  Currently there are two Atlas applications (observation-crud and crud-aggregator) along with the necessary infrastructure (Kafka, Keycloak, and Postgresql).

Docker, Helm, ytt, kbld, and kapp are required.  You can install these tools using brew.
```
brew install helm

brew tap vmware-tanzu/carvel
brew install ytt
brew install kbld
brew install kapp
```

This project uses Helm Charts from Confluent and Bitnami.  Before running any of these scripts you'll need to add these chart repositories:
```
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Air-gapped Workflow





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
