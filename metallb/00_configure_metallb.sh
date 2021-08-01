#!/bin/bash

# From https://metallb.universe.tf/

# Apply Metal LB
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.10.2/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.10.2/manifests/metallb.yaml


