#!/bin/bash

# May not be needed on Ubuntu 20.04...

# Single-name hostnames (no domain) don't work on a standard ubuntu 18.04
# install configuration of systemd-resolved.
# This can be fixed by changing the symlink to a standard list-type configuration.
#sudo ln -sf /var/run/systemd/resolve/resolv.conf /etc/resolv.conf

