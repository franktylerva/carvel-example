#!/bin/bash

kapp deploy -a atlas -f <(kubectl create ns kafka --dry-run=client -o yaml) \
    -f <(kubectl create ns atlas-infrastructure --dry-run=client -o yaml) \
    -f <(kubectl create ns atlas-observation-crud-service --dry-run=client -o yaml) \
    -f <(kubectl create configmap scripts -n atlas-observation-crud-service --from-file=./sql --dry-run=client -o yaml) \
    -f <(helm template nginx-ingress bitnami/nginx-ingress-controller --skip-tests -n atlas-infrastructure | kubectl apply -f- --dry-run=client -o yaml -n atlas-infrastructure) \
    -f <(helm template kafka confluentinc/cp-helm-charts --skip-tests --values ./kafka/values.yaml | kubectl apply -f- --dry-run=client -o yaml -n kafka) \
    -f <(helm template infrastructure ./infrastructure --skip-tests | kubectl apply -f- --dry-run=client -o yaml -n atlas-infrastructure) \
    -f <(helm template observation-crud ./observation-crud --skip-tests -n atlas-observation-crud-service | kubectl apply -f- --dry-run=client -o yaml -n atlas-observation-crud-service)
