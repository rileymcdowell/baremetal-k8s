#!/bin/bash

# Setup guide followed from
# https://github.com/kubernetes-incubator/external-storage/blob/master/nfs/docs/deployment.md

PROVISIONER_ORG=k8s-incubator
PROVISIONER_NAME=dynamic-nfs
IMG_VERSION=v2.2.1-k8s1.12
NAMESPACE=nfs

kubectl get namespaces | grep "^${NAMESPACE} " &> /dev/null
if [ "$?" -ne "0" ] ; then
    kubectl create namespace ${NAMESPACE}
fi

docker pull quay.io/kubernetes_incubator/nfs-provisioner:${IMG_VERSION}

sudo apt install nfs-common

if [ ! -d nfs_provisioner ] ; then
    mkdir -p nfs_provisioner
fi

# Setup the nfs deployment container itself
pushd nfs_provisioner
curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/deployment.yaml -o deployment.yaml
sed -i "s/example.com\\/nfs/${PROVISIONER_ORG}\\/${PROVISIONER_NAME}/" deployment.yaml
sed -i "s/latest/${IMG_VERSION}/" deployment.yaml
sed -i "s/^    spec:$/    spec:\n      nodeSelector:\n        kubernetes.io\/hostname: master0/" deployment.yaml
sed -i "s/^        kubernetes.io\/hostname: master0$/        kubernetes.io\/hostname: master0\n      tolerations:\n      - key: \"node-role.kubernetes.io\/master\"\n        operator: \"Exists\"\n        effect: \"NoSchedule\"/" deployment.yaml
mkdir -p /srv 
kubectl apply -f deployment.yaml --namespace=${NAMESPACE}
popd # nfs_provisioner

# Setup the extras
pushd nfs_provisioner

curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/psp.yaml -o psp.yaml
kubectl apply -f psp.yaml --namespace=${NAMESPACE}

curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/rbac.yaml -o rbac.yaml
sed -i "s/namespace: default/namespace: nfs/" rbac.yaml
sed -i "s/\"services\", \"endpoints\"/\"services\", \"endpoints\", \"secrets\"/" rbac.yaml # Needed for k8s 1.13.x
kubectl apply -f rbac.yaml --namespace=${NAMESPACE}

curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs/deploy/kubernetes/class.yaml -o class.yaml
sed -i "s/example.com\\/nfs/${PROVISIONER_ORG}\\/${PROVISIONER_NAME}/" class.yaml
sed -i "s/example-nfs/nfs-provisioner/" class.yaml
kubectl apply -f class.yaml --namespace=${NAMESPACE}
popd # nfs_provisioner

# Make this the new default provisioner
kubectl patch storageclass nfs-provisioner -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' --namespace=${NAMESPACE}
