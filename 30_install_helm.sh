#!/bin/bash

NAMESPACE=helm
HELM_DIR=./helm

if [ ! -d ${HELM_DIR} ] ; then
    mkdir ${HELM_DIR}
fi

# Obtain tiller and helm
pushd ${HELM_DIR}
curl https://get.helm.sh/helm-v2.14.2-linux-amd64.tar.gz -o helm.tar.gz
tar xvzf helm.tar.gz
cp ./linux-amd64/helm ~/bin
cp ./linux-amd64/tiller ~/bin/
popd # ${HELM_DIR}

kubectl create namespace ${NAMESPACE} 
kubectl --namespace=${NAMESPACE} apply -f ${HELM_DIR}/helm-service-account.yaml
kubectl --namespace=${NAMESPACE} apply -f ${HELM_DIR}/helm-role-binding.yaml

# Initialize helm
helm init --tiller-namespace=${NAMESPACE} --service-account tiller --history-max 200 --wait

# Get helm up to date
helm repo update
