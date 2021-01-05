#!/bin/bash

set -e

echo "aws version"

aws --version

echo "Attempting to update kubeconfig for aws"

aws eks --region "$AWS_REGION" update-kubeconfig --name "$CLUSTER_NAME"
kubectl apply -f kustomize/base/tools/job-eks.yaml

while [[ $(kubectl get pods -l job-name=kube-bench -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done

POD=$(kubectl get pod -l job-name=kube-bench -o jsonpath="{.items[0].metadata.name}")
kubectl logs $POD > kube-bench-report.json