#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Connecting to gitlab...${NC}"
GITLAB_PASS=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)
sudo echo "machine gitlab.k3d.gitlab.com:2000
login root
password ${GITLAB_PASS}" > ~/.netrc
sudo mv ~/.netrc /root/
sudo chmod 600 /root/.netrc

# clone repo
echo -e "${GREEN}Cloning repo...${NC}"
sudo git clone http://gitlab.k3d.gitlab.com:2000/root/jnguyen_bonus.git git_lab

# clone repo from github
sudo git clone https://github.com/Ljulienng/jnguyen_iotp3.git git_hub

echo -e "${GREEN}Copying repo github to gitlab...${NC}"
# copy from git_hub and git_lab
sudo mv git_hub/* git_lab/

echo -e "${GREEN}Deleting github repo...${NC}"
sudo rm -rf git_hub/

echo -e "${GREEN}Pushing Gitlab repo...${NC}"
cd git_lab
sudo git add *
sudo git commit -m "update"
sudo git push
cd ..

echo -e "${GREEN}Apply deployment...${NC}"
kubectl apply -f ./confs/deployment.yaml

kubectl -n dev wait --for=condition=Ready pods --all

# Warning port-forward
echo "${GREEN}PORT-FORWARD : kubectl port-forward svc/svc-wil -n dev 8888:8080${RESET}"