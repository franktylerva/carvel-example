#!/bin/bash

rm -rf bundle
mkdir -p bundle/.imgpkg

OUTPUT=bundle/config.yml

echo "Generating the k8s Configuration..."

helm template kafka confluentinc/cp-helm-charts --skip-tests --values ./kafka/values.yaml | ytt -f- -f ./kafka/config/ > $OUTPUT

echo "Generating the bundle..."

kbld -f bundle/config.yml --imgpkg-lock-output bundle/.imgpkg/images.yml

echo "Pushing the bundle to harbor.cp.az.km.spaceforce.mil/legos-test/kafka:7.0.1..."

imgpkg push -b harbor.cp.az.km.spaceforce.mil/legos-test/kafka:7.0.1 -f bundle