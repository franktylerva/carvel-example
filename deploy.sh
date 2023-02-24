#!/bin/bash

# No ordering of Keycloak and Kafka Helm Charts
kapp deploy -a system -f <(kubectl create ns kafka --dry-run=client -o yaml) \
    -f <(kubectl create ns infrastructure --dry-run=client -o yaml) \
    -f <(kubectl create ns observation-crud-service --dry-run=client -o yaml) \
    -f <(kubectl create ns keycloak --dry-run=client -o yaml) \
    -f <(kubectl create ns orbital-crud-service --dry-run=client -o yaml) \
    -f <(kubectl create ns sensor-crud-service --dry-run=client -o yaml) \
    -f <(helm template keycloak bitnami/keycloak --skip-tests --values ./keycloak/values.yaml -n keycloak) \
    -f <(kubectl create configmap scripts -n observation-crud-service --from-file=./sql --dry-run=client -o yaml) \
    -f <(helm template kafka confluentinc/cp-helm-charts --skip-tests --values ./kafka/values.yaml) \
    -f <(helm template infrastructure ./infrastructure --skip-tests | kubectl apply -f- --dry-run=client -o yaml -n infrastructure) \
    -f <(helm template observation-crud bitnami/postgresql --skip-tests -n observation-crud-service --values ./postgresql/values.yaml | kubectl apply -f- --dry-run=client -o yaml -n observation-crud-service) \
    -f <(helm template observation-crud ./observation-crud --skip-tests -n observation-crud-service | kubectl apply -f- --dry-run=client -o yaml -n observation-crud-service) \
    -f <(helm template crud-aggregator ./crud-aggregator --skip-tests -n observation-crud-service | kubectl apply -f- --dry-run=client -o yaml -n observation-crud-service)