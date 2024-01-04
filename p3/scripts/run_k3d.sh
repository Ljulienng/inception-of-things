#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color


echo -e "${GREEN}[INFO] Setting up our cluster with 2 worker nodes${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${GREEN}[INFO] Installing Docker${NC}"
    sudo apt install docker
else
    echo -e "${GREEN}[INFO] Docker already installed${NC}"
fi

sudo chmod 666 /var/run/docker.sock
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
k3d cluster create argocd
echo "alias k='kubectl'" >> ~/.bashrc # way to add alias on all users
sleep 5

export KUBECONFIG="$(k3d kubeconfig write argocd)"


echo -e "${GREEN}[INFO] Creating argocd and dev namespace${NC}"
kubectl create namespace argocd
kubectl create namespace dev

echo -e "${GREEN}[INFO] Installing ArgoCD${NC}"
kubectl apply -n argocd -f install.yaml

echo -e "${GREEN}[INFO] Waiting for ArgoCD deployment...${NC}"
kubectl wait -n argocd --for=condition=available --timeout=180s deployment/argocd-server

echo -e "${GREEN}[INFO] Changing ArgoCD admin password...${NC}"
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": "$2a$12$HxOhjUJ3NQjMd3R4l4XGPO1LlCHuGjxu.vTBpf6SnegJdDIyvmCme", "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'

echo -e "${GREEN}[INFO] Deploying application${NC}"
kubectl apply -f ../confs/deployment.yaml

kubectl -n dev wait --for=condition=Ready pods --all


# echo -e "${GREEN}[INFO] Waiting for deployment and pods...${NC}"

# # Check if pods are running
# echo -e "${GREEN}[INFO] Monitoring pods status...${NC}"
# # while true; do
#     kubectl get pods -n argocd -o wide
#     sleep 10
#     echo -e "${GREEN}----------------------------------------${NC}"
# done &

# Background job PID
# BG_PID=$!

sleep 10


echo -e "${GREEN}[INFO] Starting port-forwarding for ArgoCD server...${NC}"
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 &

# sudo kubectl port-forward svc/wil-playground -n dev 8888:8888 2>&1 >/dev/null &
# Wait for a user input to kill the background job
# read -p "Press [ENTER] to stop monitoring pods..."
# kill $BG_PID