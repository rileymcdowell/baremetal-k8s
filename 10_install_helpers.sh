#!/bin/bash

if [ ! -d ${HOME}/bin ] ; then
    mkdir ${HOME}/bin
fi

pushd ${HOME}/bin
    if [ ! -f ./kompose ] ; then
        curl -L https://github.com/kubernetes/kompose/releases/download/v1.22.0/kompose-linux-amd64 -o kompose
        chmod 700 ./kompose
    fi
popd

cat ${HOME}/.bashrc | grep '# Add kubernetes autocompletion' &> /dev/null
if [ "$?" != "0" ] ; then
cat << EOF >> ${HOME}/.bashrc
# Add kubernetes autocompletion
source <(kubeadm completion bash)
source <(kubectl completion bash)
source <(/home/$USER/bin/kompose completion bash)
EOF
fi

