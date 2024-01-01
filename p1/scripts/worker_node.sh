#!/bin/bash

# Replace this with your master node's IP address
MASTER_IP="192.168.56.110"

# Path to the file containing the node token
TOKEN_FILE="/vagrant/token.env"

# https://docs.k3s.io/installation/configuration#configuration-file
# Check if the token file exists and read the token
if [ -f "$TOKEN_FILE" ]; then
    NODE_TOKEN=$(cat "$TOKEN_FILE")
else
    echo "Node token file not found"
    exit 1
fi

export INSTALL_K3S_EXEC="agent --server https://${MASTER_IP}:6443 -t ${NODE_TOKEN} --node-ip=192.168.56.111"
# https://docs.k3s.io/quick-start
# Download and install K3s agent
curl -sfL https://get.k3s.io | sh -

echo "[INFO]  Doing some sleep to wait for k3s to be ready"

sleep 10

if sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.111/24 dev eth1 && sudo ip link set eth1 up; then
    echo -e "success, eth1 added"
else
    echo -e "failed, eth1 wasn't added (already added ?)"
fi


# sudo rm /vagrant/token.env
