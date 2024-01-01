#!/bin/bash

echo "[INFO]  Installing k3s on server node (ip: $1)"

export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san jnguyenS --node-ip $1  --bind-address=$1 --advertise-address=$1 "

echo "[INFO]  ARGUMENT PASSED TO INSTALL_K3S_EXEC: $INSTALL_K3S_EXEC"

apk add curl

curl -sfL https://get.k3s.io |  sh -

echo "[INFO]  Doing some sleep to wait for k3s to be ready"

sleep 10

sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/token.env

echo "[INFO]  Successfully installed k3s on server node"

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh # way to add alias on all users

if sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.110/24 dev eth1 && sudo ip link set eth1 up; then
    echo -e "success, eth1 added"
else
    echo -e "failed, eth1 wasn't added (already added ?)"
fi