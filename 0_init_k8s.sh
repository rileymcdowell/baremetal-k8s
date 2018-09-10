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
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
fi

# Set up the cluster
sudo kubeadm init

# Set up the individual user
if [ ! -d $HOME/.kube ] ; then
    mkdir -p $HOME/.kube
fi
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Make the master into a node
kubectl taint nodes --all node-role.kubernetes.io/master-

echo "Kubernetes Init Script Complete!"

