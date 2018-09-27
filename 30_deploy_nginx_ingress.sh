#!/bin/bash

# NGINX Ingress Controller for Bare Metal Kubernetes
# Source: https://kubernetes.github.io/ingress-nginx/deploy/

# Apply the mandatory stuff.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

# Apply the bare-metal service config
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml

echo "Done with nginx-ingress!"
