#!/bin/bash

# Based in part on https://blog.lwolf.org/post/how-i-deployed-glusterfs-cluster-to-kubernetes/
# Also based on https://github.com/heketi/heketi/blob/master/docs/admin/install-kubernetes.md

USER_BIN_DIR=${HOME}/bin
USER_SRC_DIR=${HOME}/src

sudo iptables -N HEKETI
sudo iptables -A HEKETI -p tcp -m state --state NEW -m tcp --dport 24007 -j ACCEPT
sudo iptables -A HEKETI -p tcp -m state --state NEW -m tcp --dport 24008 -j ACCEPT
sudo iptables -A HEKETI -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
sudo iptables -A HEKETI -p tcp -m state --state NEW -m multiport --dports 49152:49251 -j ACCEPT
sudo iptables-save


# Make sure directories exist
if [ ! -d ${USER_SRC_DIR} ] ; then
    mkdir -p ${USER_SRC_DIR}
fi
if [ ! -d ${USER_BIN_DIR} ] ; then
    mkdir -p ${USER_BIN_DIR}
fi


# Download and unpack the client
pushd ${USER_SRC_DIR}
if [ ! -f ${USER_SRC_DIR}/heketi-client-v8.0.0.linux.amd64.tar.gz ] ; then
    wget https://github.com/heketi/heketi/releases/download/v8.0.0/heketi-client-v8.0.0.linux.amd64.tar.gz
fi
if [ ! -d ${USER_SRC_DIR}/heketi-client ] ; then
    tar xvzf heketi-client-v8.0.0.linux.amd64.tar.gz
fi
popd # ${USER_SRC_DIR}


# Put the client in the user's bin path
if [ ! -f ${USER_BIN_DIR}/heketi-cli ] ; then
    cp ${USER_SRC_DIR}/heketi-client/bin/heketi-cli ${USER_BIN_DIR}/heketi-cli
fi

# Apply the glusterfs daemonset.
kubectl apply -f ${USER_SRC_DIR}/heketi-client/share/heketi/kubernetes/glusterfs-daemonset.json

# Mark the slave nodes as glusterfs nodes
NODES=$(kubectl get nodes | tr -s ' ' | cut -f 1 -d ' ' | grep -v NAME | grep slave)
for node in $NODES; do
    kubectl label node $node storagenode=glusterfs
done

# Create the heketi service account
kubectl apply -f ${USER_SRC_DIR}/heketi-client/share/heketi/kubernetes/heketi-service-account.json

# Allow the service account to control the gluster pods
kubectl create clusterrolebinding heketi-gluster-admin --clusterrole=edit --serviceaccount=default:heketi-service-account

# Create a kubernetes secret to allow volume setup
kubectl create secret generic heketi-config-secret --from-file=${USER_SRC_DIR}/heketi-client/share/heketi/kubernetes/heketi.json

# Modify the heketi bootstrap to put a load balancer on the heketi service
cp ./heketi_glusterfs/modify_service.py ${USER_SRC_DIR}/heketi-client/share/heketi/kubernetes/
${USER_SRC_DIR}/heketi-client/share/heketi/kubernetes/modify_service.py

# Apply the heketi bootstrap with modified load balancer
kubectl apply -f ${USER_SRC_DIR}/heketi-client/share/heketi/kubernetes/heketi-bootstrap-lb.json

# Set the environment variable for the HEKETI_CLI_SERVER to the load-balancer IP
cat ${HOME}/.bashrc | grep '# Add heketi cli config' &> /dev/null
if [ "$?" != "0" ] ; then
cat << EOF >> ${HOME}/.bashrc
# Add heketi cli config
export HEKETI_CLI_SERVER="http://192.168.2.193:8080
EOF
fi

# Also export the HEKETI_CLI_SERVER in this session
export HEKETI_CLI_SERVER="http://192.168.2.193:8080"

# Describe the topology of the glusterfs volumes on the nodes in json format,
# then load it to heketi using the CLI
pushd heketi_glusterfs
./create_topology.py
heketi-cli topology load --json ./heketi-topology.json
popd # heketi_glusterfs

# Enable the needed kernel module on all nodes.
modprobe dm_thin_pool

# Provision a volume for heketi itself. This is built in!
pushd heketi_glusterfs
heketi-cli setup-openshift-heketi-storage
popd # heketi_glusterfs


