#!/bin/bash

# Weave Net for Networking
# Source: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "Weavenet Loaded."
