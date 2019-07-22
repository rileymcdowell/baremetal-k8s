#!/bin/bash

# Weave Net for Networking
# Source: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

if [ ! -d weavenet ] ; then
    mkdir -p weavenet
fi

# Pass the NO_MASQ_LOCAL flag to enable service.spec.externalTrafficPolicy=Local flag
# This allows services to see the originating IP instead of the masq-ed weavenet ip.
# It's slightly less efficient, but we don't care for a tiny baremetal cluster.

pushd weavenet
curl "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
-o weavenet.yaml
kubectl apply -f weavenet.yaml
popd

echo "Weavenet Loaded."
