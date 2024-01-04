#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# install git
sudo apt install git

# after install k3d cluster create gitlab namespace
kubectl create namespace gitlab

# cheking and add host
HOST_ENTRY="127.0.0.1 gitlab.k3d.gitlab.com"
HOSTS_FILE="/etc/hosts"

if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo "exist $HOSTS_FILE"
else
    echo "adding $HOSTS_FILE"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi
 
# Deploy GitLab using Helm
helm repo add gitlab https://charts.gitlab.io/
helm repo update 
helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=k3d.gitlab.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

echo -e "${RED}Waiting for GitLab Webservice to be ready...${NC}"
kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

# password to gitlab (user: root)
echo -n "${GREEN}GITLAB PASSWORD : "
    kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode
    kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode > password.txt
echo "${NC}"

# argocd localhost:80 or http://gitlab.k3d.gitlab.com
kubectl port-forward svc/gitlab-webservice-default -n gitlab 2000:8181 2>&1 >/dev/null &


echo -e "${GREEN}GitLab Deployed! Access it at http://gitlab.k3d.gitlab.com:2000/${NC}"