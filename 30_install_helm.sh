#!/bin/bash

NAMESPACE=helm
HELM_DIR=./helm

if [ ! -d ${HELM_DIR} ] ; then
    mkdir ${HELM_DIR}
fi

# Obtain tiller and helm
pushd ${HELM_DIR}
curl https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz -o helm.tar.gz
tar xvzf helm.tar.gz
cp ./linux-amd64/helm ~/bin
popd # ${HELM_DIR}

# Add a helm repo
helm repo add "stable" "https://charts.helm.sh/stable" --force-update

# Get helm up to date
helm repo update
