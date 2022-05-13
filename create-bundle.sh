#!/bin/bash

rm -rf bundle
mkdir -p bundle/.imgpkg

OUTPUT=bundle/config-temp.yml

echo "Generating the k8s Configuration..."

 > $OUTPUT
echo --- >> $OUTPUT

kubectl create ns atlas-infrastructure --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns atlas-observation-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns keycloak --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns atlas-orbital-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

kubectl create ns atlas-sensor-crud-service --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template keycloak bitnami/keycloak --skip-tests --values ./keycloak/values.yaml -n keycloak >> $OUTPUT
echo --- >> $OUTPUT

kubectl create configmap scripts -n atlas-observation-crud-service --from-file=./sql --dry-run=client -o yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template kafka confluentinc/cp-helm-charts --skip-tests --values ./kafka/values.yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template infrastructure ./infrastructure --skip-tests >> $OUTPUT
echo --- >> $OUTPUT

helm template observation-crud bitnami/postgresql --skip-tests -n atlas-observation-crud-service --values ./postgresql/values.yaml >> $OUTPUT
echo --- >> $OUTPUT

helm template observation-crud ./observation-crud --skip-tests -n atlas-observation-crud-service >> $OUTPUT
echo --- >> $OUTPUT

helm template crud-aggregator ./crud-aggregator --skip-tests -n atlas-observation-crud-service >> $OUTPUT
echo --- >> $OUTPUT

echo "Generating the bundle..."

kbld -f bundle/config.yml --imgpkg-lock-output bundle/.imgpkg/images.yml

echo "Pushing the bundle to harbor.cp.az.km.spaceforce.mil/legos-test/atlas:1.0.0..."

imgpkg push -b harbor.cp.az.km.spaceforce.mil/legos-test/atlas:1.0.0 -f bundle
