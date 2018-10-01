#!/bin/bash

# Setup guide followed from
# https://github.com/kubernetes-incubator/external-storage/blob/master/nfs/docs/deployment.md

PROVISIONER_ORG=k8s-incubator
PROVISIONER_NAME=dynamic-nfs
IMG_VERSION=v2.1.0-k8s1.11

docker pull quay.io/kubernetes_incubator/nfs-provisioner:${IMG_VERSION}


if [ ! -d nfs_provisioner ] ; then
    mkdir -p nfs_provisioner
fi

# Setup the nfs deployment container itself
pushd nfs_provisioner
curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/deployment.yaml -o deployment.yaml
sed -i "s/example.com\\/nfs/${PROVISIONER_ORG}\\/${PROVISIONER_NAME}/" deployment.yaml
sed -i "s/latest/${IMG_VERSION}/" deployment.yaml
mkdir -p /srv 
kubectl apply -f deployment.yaml
popd # nfs_provisioner

# Setup the extras
pushd nfs_provisioner
kubectl apply -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/psp.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/rbac.yaml
curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/class.yaml -o class.yaml
sed -i "s/example.com\\/nfs/${PROVISIONER_ORG}\\/${PROVISIONER_NAME}/" class.yaml
sed -i "s/example-nfs/nfs-provisioner/" class.yaml
kubectl apply -f class.yaml
popd # nfs_provisioner

# Make this the new default provisioner
kubectl patch storageclass nfs-provisioner -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
