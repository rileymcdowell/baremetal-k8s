#!/bin/bash

which docker &> /dev/null
if [ ! "$?" == "0" ] ; then
    sudo apt-get update
    sudo apt-get install \
	apt-transport-https \
	ca-certificates \
	curl \
	software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    sudo apt-get update
    sudo apt-get install docker-ce
    sudo usermod -aG docker $USER
fi

which kubectl &> /dev/null
if [ ! "$?" == "0" ] ; then
    sudo apt-get update 
    sudo apt-get install -y apt-transport-https curl
    sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet=1.13.8-00 kubeadm=1.13.8-00 kubectl=1.13.8-00
    sudo apt-mark hold kubelet kubeadm kubectl
fi

# Disable swap now
sudo swapoff -a
# Disable swap permanently
sudo sed -i 's/^\/swap.img/# No swap for k8s\n#\/swap.img/' /etc/fstab

# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
# Set up the cluster
sudo kubeadm init --kubernetes-version=$(kubeadm version --output short)

# Set up the individual user
if [ ! -d $HOME/.kube ] ; then
    mkdir -p $HOME/.kube
fi
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Kubernetes Init Script Complete!"

