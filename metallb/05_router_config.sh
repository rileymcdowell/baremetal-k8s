#!/bin/bash

# Config for ubiquiti edgerouter x
# Based on https://medium.com/@ipuustin/using-metallb-as-kubernetes-load-balancer-with-ubiquiti-edgerouter-7ff680e9dca3
# Also
# https://help.ubnt.com/hc/en-us/articles/205222990-EdgeRouter-Border-Gateway-Protocol

# $> configure
# $> set protocols bgp 64512 parameters router-id 192.168.1.1
# $> set protocols bgp 64512 neighbor 192.168.1.4 remote-as 64512
# $> set protocols bgp 64512 maximum-paths ibgp 32
# $> commit
# $> save 
# $> exit 

echo "Run this on the router, not on the cluster."
