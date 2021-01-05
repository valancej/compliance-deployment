#!/bin/bash

set -e

echo "aws version"

aws --version

echo "Attempting to update kubeconfig for aws"

aws eks --region "$AWS_REGION" update-kubeconfig --name "$CLUSTER_NAME"
kubectl apply -f kustomize/base/tools/job-eks.yaml

while [[ $(kubectl get job kube-bench -o 'jsonpath={..status.conditions[?(@.type=="Complete")].status}') != "True" ]]; do echo "waiting for job" && sleep 1; done

POD=$(kubectl get pod -l job-name=kube-bench -o jsonpath="{.items[0].metadata.name}")
kubectl logs $POD > kube-bench-report.json
ls