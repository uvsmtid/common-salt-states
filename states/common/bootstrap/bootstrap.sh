#!/bin/sh

set -x
set -e
set -u

# Get minion id.
selected_host_name="${1}"
# Get Salt master IP address.
salt_master_ip="${2}"

# Install Salt minion.
sudo yum install -y salt-minion

# Configure Salt minion.
sudo cp ./host_configs/${selected_host_name}/minion.conf /etc/salt/minion

# Make sure `salt` hostname is resolvable:
sudo echo "${salt_master_ip} salt" >> /etc/hosts

# Start Salt minion service.
sudo systemctl start salt-minion

