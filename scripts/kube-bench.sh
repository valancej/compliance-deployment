#!/bin/bash

set -e

echo "aws version"

aws --version

echo "Attempting to update kubeconfig for aws"

aws eks --region "$AWS_REGION" update-kubeconfig --name "$CLUSTER_NAME"

# Apply EKS kube-bench job
kubectl apply -f kustomize/base/tools/job-eks.yaml

while [[ $(kubectl get job kube-bench -o 'jsonpath={..status.conditions[?(@.type=="Complete")].status}') != "True" ]]; do echo "waiting for job" && sleep 1; done

POD=$(kubectl get pod -l job-name=kube-bench -o jsonpath="{.items[0].metadata.name}")
kubectl logs $POD > artifacts/kube-bench-report.json

# Apply CIS benchmark job
kubectl apply -f kustomize/base/tools/job-cis-benchmark.yaml

while [[ $(kubectl get job anchore-cis-bench -o 'jsonpath={..status.conditions[?(@.type=="Complete")].status}') != "True" ]]; do echo "waiting for job" && sleep 1; done

CISPOD=$(kubectl get pod -l job-name=anchore-cis-bench -o jsonpath="{.items[0].metadata.name}")
kubectl logs $CISPOD > artifacts/anchore-cis-bench-report.json

ls -R