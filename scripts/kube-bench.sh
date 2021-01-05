#!/bin/sh

set -e

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"

echo "aws version"

aws --version

echo "Attempting to update kubeconfig for aws"

aws eks --region "$AWS_REGION" update-kubeconfig --name "$CLUSTER_NAME"
kubectl apply -f kustomize/base/tools/job-eks.yaml
POD=$(kubectl get pod -l job-name=kube-bench -o jsonpath="{.items[0].metadata.name}")
kubectl logs $POD > kube-bench-report.json