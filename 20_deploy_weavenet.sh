#!/bin/bash

# Weave Net for Networking
# Source: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

if [ ! -d weavenet ] ; then
    mkdir -p weavenet
fi

pushd weavenet
# Pass the NO_MASQ_LOCAL query param to enable service.spec.externalTrafficPolicy=Local flag
# This allows services to see the originating IP instead of the masq-ed weavenet ip.
# It's slightly less efficient, but we don't care for a tiny baremetal cluster.
curl "https://cloud.weave.works/k8s/v1.10/net.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.NO_MASQ_LOCAL=1" -o weavenet.yaml
kubectl apply -f weavenet.yaml
popd

echo "Weavenet Loaded."
