#!/usr/bin/env python3

"""
The purpose of this script is to add a LoadBalancer external IP to the cluster
for the heketi service. On a home kubernetes cluster, there's no need to 
hide it behind layers of networking.
"""

import os
import copy
import json
import codecs

_this_dir = os.path.dirname(__file__)

source_file = os.path.join(_this_dir, './heketi-bootstrap.json')
backup_file = os.path.join(_this_dir, './heketi-bootstrap.json.bak')
output_file = os.path.join(_this_dir, './heketi-bootstrap-lb.json')

if os.path.exists(source_file):
    os.rename(source_file, backup_file)

with open(backup_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Write out a new version with a LoadBalancer on the service.
lb_data = copy.deepcopy(data)
for item in lb_data['items']:
    if item['kind'] == "Service":
        item['spec']['type'] = 'LoadBalancer'
        item['spec']['loadBalancerIP'] = '192.168.2.193'
    else:
        continue # Wrong element of the bootstrap file.
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(lb_data, f, indent=2)

