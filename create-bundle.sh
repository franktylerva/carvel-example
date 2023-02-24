#!/bin/bash

rm -rf bundle
mkdir -p bundle/.imgpkg

OUTPUT=bundle/config.yml

echo "Generating the k8s Configuration..."

 > $OUTPUT
echo --- >> $OUTPUT

kubectl create ns infrastructure --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns observation-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns keycloak --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns kafka --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns orbital-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns sensor-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template kafka confluentinc/cp-helm-charts --skip-tests --values ./kafka/values.yaml | ytt -f- -f ./kafka/config/ >> $OUTPUT
echo --- >> $OUTPUT

helm template keycloak bitnami/keycloak --skip-tests --values ./keycloak/values.yaml -n keycloak >> $OUTPUT
echo --- >> $OUTPUT

kubectl create configmap scripts -n observation-crud-service --from-file=./sql --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template infrastructure ./infrastructure --skip-tests >> $OUTPUT
echo --- >> $OUTPUT

helm template app2 bitnami/postgresql --skip-tests -n observation-crud-service --values ./postgresql/values.yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template app2 ./app2 --skip-tests -n sensor-crud-service >> $OUTPUT
echo --- >> $OUTPUT

helm template app1 ./app1 --skip-tests -n observation-crud-service >> $OUTPUT
echo --- >> $OUTPUT