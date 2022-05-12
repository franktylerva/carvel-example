#!/bin/bash

rm -rf bundle
mkdir -p bundle/.imgpkg

OUTPUT=bundle/config-temp.yml

echo "Generating the k8s Configuration..."

helm template kafka confluentinc/cp-helm-charts --skip-tests --values ./kafka/values.yaml > $OUTPUT

echo "Generating the bundle..."

kbld -f bundle/config-temp.yml --imgpkg-lock-output bundle/.imgpkg/images.yml > bundle/config.yml

rm bundle/config-temp.yml