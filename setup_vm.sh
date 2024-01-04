#!/bin/bash


function check_virtualbox() {
  if command -v VBoxManage >/dev/null 2>&1; then
    echo "VirtualBox is already installed."
  else
    echo "Installing VirtualBox..."
    sudo apt install virtualbox || exit 1
  fi
}

# Function to check if Vagrant is installed
function check_vagrant() {
  if command -v vagrant >/dev/null 2>&1; then
    echo "Vagrant is already installed."
  else
    echo "Installing Vagrant..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vagrant || exit 1
  fi
}

# Function to check if Kubectl is installed
function check_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    echo "Kubectl is already installed."
  else
    echo "Installing Kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(<kubectl.sha256) kubectl" | sha256sum --check
    chmod +x kubectl
    sudo mv ./kubectl /usr/local/bin || exit 1
  fi
}

# Function to check if K3d is installed
function check_k3d() {
  if command -v k3d >/dev/null 2>&1; then
    echo "K3d is already installed."
  else
    echo "Installing K3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.0.0 bash
    echo "source <(k3d completion bash)" >> ~/.bashrc || exit 1
  fi
}

sudo apt install curl
sudo snap install docker

# Call the functions
check_virtualbox
check_vagrant
check_kubectl
check_k3d