#!/bin/bash

# NGINX Ingress Controller for Bare Metal Kubernetes
# Source: https://kubernetes.github.io/ingress-nginx/deploy/
# Modified to use fixed NodePorts for the nginx proxy.

pushd deployments/ingress-nginx

# Delete any previous config
rm ./*.yaml

# Apply the mandatory stuff unchanged.
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml -o mandatory.yaml
kubectl apply -f mandatory.yaml

# Apply the bare-metal service config, modified to use fixed nodePorts and clusterIP
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml -o service-nodeport.yaml
# We need to alter the nodeport service to use fixed nodeports
# so nginx knows where to go.
sed -i '/^  ports:/,/^  selector:/{/^  ports:/!{/^  selector:/!d}}' service-nodeport.yaml # Remove the port specs.
sed -i 's/ports:/ports:\n  - name: port80\n    port: 80\n    nodePort: 30080\n    targetPort: 80\n    protocol: TCP/' service-nodeport.yaml
sed -i 's/ports:/ports:\n  - name: port443\n    port: 443\n    nodePort: 30443\n    targetPort: 443\n    protocol: TCP/' service-nodeport.yaml
sed -i 's/ports:/ports:\n  - name: port8080\n    port: 8080\n    nodePort: 31080\n    targetPort: 8080\n    protocol: TCP/' service-nodeport.yaml
sed -i 's/ports:/ports:\n  - name: port8443\n    port: 8443\n    nodePort: 31443\n    targetPort: 8443\n    protocol: TCP/' service-nodeport.yaml
sed -i 's/ports:/ports:\n  - name: port8843\n    port: 8843\n    nodePort: 31843\n    targetPort: 8843\n    protocol: TCP/' service-nodeport.yaml
sed -i 's/ports:/ports:\n  - name: port8880\n    port: 8880\n    nodePort: 31880\n    targetPort: 8880\n    protocol: TCP/' service-nodeport.yaml
sed -i 's/ports:/ports:\n  - name: port3478\n    port: 3478\n    nodePort: 31478\n    targetPort: 3478\n    protocol: UDP/' service-nodeport.yaml
sed -i 's/ports:/ports:\n  - name: port6789\n    port: 6789\n    nodePort: 31789\n    targetPort: 6789\n    protocol: TCP/' service-nodeport.yaml
sed -i 's/ports:/ports:\n  - name: port10001\n    port: 10001\n    nodePort: 31001\n    targetPort: 10001\n    protocol: UDP/' service-nodeport.yaml
sed -i 's/type: NodePort/type: NodePort\n  clusterIP: 10.96.96.96/' service-nodeport.yaml
kubectl apply -f service-nodeport.yaml

# Only 80 and 443 are supported with annotations, so use ConfigMap for the rest.
cat << EOF >> tcp-services.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  8080: "default/unifi:8080"
  8443: "default/unifi:8443"
  8843: "default/unifi:8843"
  8880: "default/unifi:8880"
  6789: "default/unifi:6789"
EOF
kubectl apply -f tcp-services.yaml


# Same, but for UDP services.
cat << EOF >> udp-services.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: udp-services
  namespace: ingress-nginx
data:
  3478: "default/unifi:3478"
  10001: "default/unifi:10001"
EOF
kubectl apply -f udp-services.yaml

popd

echo "Done with nginx-ingress!"
