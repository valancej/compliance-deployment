#!/bin/bash

set -Eeuo pipefail
# Convert labels from the compliance manifest into annotations for deployment

echo "Converting labels from hardening manifest into annotations"
pod_annotations=$(while IFS= read -r annotation; do
  echo "podAnnotations.$annotation" 
done < "artifacts/pod-annotations.env")

helm_set_annotations=$(echo $pod_annotations | tr ' ' ,)

IFS=$'\n'

echo $helm_set_annotations

cd kustomize/base
helm template example-webapp ../../example-webapp --values ../../example-webapp/values.yaml --set $helm_set_annotations --set image.tag=$GITHUB_SHA > example-webapp-template.yaml --debug
cat kustomization.yaml
kustomize build
