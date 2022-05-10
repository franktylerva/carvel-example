# atlas-local
This repository is used for setting up Atlas applications in a local development environment for demonstration and testing purposes.  Several tools are used from the Carvel project to demonstrate overlays (ytt) and ordered deployments (kapp).  This project also demonstrates how these tools work with other deployment technologies such as Helm, kustomize, and plain old k8s yaml files.

Both the kapp and Helm are required.  Install these tools using brew.
```
brew install helm

brew tap vmware-tanzu/carvel
brew install kapp
brew install ytt
```

If you don't already have the Confluent Helm Chart repository configured, run the following commands.
```
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo update
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
