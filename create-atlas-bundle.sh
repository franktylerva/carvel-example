#!/bin/bash

rm -rf bundle
mkdir -p bundle/.imgpkg

OUTPUT=bundle/config.yml

echo "Generating the k8s Configuration..."

 > $OUTPUT
echo --- >> $OUTPUT

kubectl create ns atlas-infrastructure --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns atlas-observation-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns keycloak --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns kafka --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns atlas-orbital-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns atlas-sensor-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template kafka confluentinc/cp-helm-charts --skip-tests --values ./kafka/values.yaml | ytt -f- -f ./kafka/config/ >> $OUTPUT
echo --- >> $OUTPUT

helm template keycloak bitnami/keycloak --skip-tests --values ./keycloak/values.yaml -n keycloak >> $OUTPUT
echo --- >> $OUTPUT

kubectl create configmap scripts -n atlas-observation-crud-service --from-file=./sql --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template infrastructure ./infrastructure --skip-tests >> $OUTPUT
echo --- >> $OUTPUT

helm template observation-crud bitnami/postgresql --skip-tests -n atlas-observation-crud-service --values ./postgresql/values.yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template observation-crud ./observation-crud --skip-tests -n atlas-observation-crud-service >> $OUTPUT
echo --- >> $OUTPUT

helm template crud-aggregator ./crud-aggregator --skip-tests -n atlas-observation-crud-service >> $OUTPUT
echo --- >> $OUTPUT