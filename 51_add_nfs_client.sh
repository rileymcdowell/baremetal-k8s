#!/bin/bash

NAMESPACE=nfs
HELM_CHART=nfs-client-provisioner
NAME=nfs-client

kubectl get namespaces | grep ${NAMESPACE} &> /dev/null
if [ "$?" -ne "0" ] ; then
    kubectl create namespace ${NAMESPACE} 
fi


# Maybe clean up nfs
helm --namespace=${NAMESPACE} list | grep "${NAME}" &> /dev/null
if [ "$?" -eq "0" ] ; then
    helm delete ${NAME} --purge
fi


# Install nfs-client-provisioner with custom values
helm install stable/${HELM_CHART} \
	--tiller-namespace helm \
	--namespace ${NAMESPACE} \
	--set nfs.server=nas.lan \
	--set nfs.path=/volume1/k8s \
	--set storageClass.defaultClass=true \
	--name ${NAME} 


