#!/usr/bin/env python3

"""
The purpose of this file is to build a heketi topology file
for managing volumes for glusterfs.

The topology setup is described here.
https://github.com/heketi/heketi/blob/master/docs/admin/topology.md
"""

import os
import json
import codecs
import subprocess

_this_dir = os.path.dirname(__file__)
out_file = os.path.join(_this_dir, 'heketi-topology.json')

out_dict = { "clusters": [
               { "nodes": [ ] }
             ]
           }

ZONE_NUMBER = 1
BLOCK_DEVICE = { "name": "/dev/sda3", "destroydata": False }

# Iterate the nodes of the cluster.
def iter_all_nodes():
    ip_bytes = subprocess.check_output(['kubectl', 'get', 'nodes', '--output=json'])
    ip_str = codecs.decode(ip_bytes, 'utf-8')
    ip_dict = json.loads(ip_str)
    for elem in ip_dict['items']:
        if elem['kind'] != 'Node':
            continue # Only care about nodes.
        addresses = elem['status']['addresses']
        node_info = {}
        for address in addresses:
            if address['type'] == 'InternalIP':
                node_info['ip'] = address['address']
            if address['type'] == 'Hostname':
                node_info['name'] = address['address']
        if 'node-role.kubernetes.io/master' in elem['metadata']['labels']:
            node_info['role'] = 'master'
        else:
            node_info['role'] = 'slave'
        yield node_info


# Configure all non-master nodes.
for node in iter_all_nodes():
    if node['role'] != 'master':
        heketi_node_config = { 
                               "node": { 
                                 "hostnames": { "manage": [node['name']] 
                                              , "storage": [node['ip']]
                                              },
                                 "zone": ZONE_NUMBER,
                               },
                               "devices": [BLOCK_DEVICE]
                             }
        out_dict["clusters"][0]['nodes'].append(heketi_node_config)


# Write out the configuration to disk to load with the cli
with open(out_file, 'w', encoding='utf-8') as f:
    json.dump(out_dict, f, indent=2)


