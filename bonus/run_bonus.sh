#!/bin/bash

export EMAIL="jnguyen@student.42.fr"
export DOMAIN="gitlab.jnguyen.com"
export KUBECONFIG="/etc/rancher/k3s/k3s.yaml"

kubectl create namespace gitlab

helm repo add gitlab https://charts.gitlab.io/

helm search repo gitlab

helm install gitlab gitlab/gitlab --set global.hosts.domain=$DOMAIN --set certmanager-issuer.email=$EMAIL --set global.hosts.https="false" --set global.ingress.configureCertmanager="false" --set gitlab-runner.install="false" -n gitlab

echo -n "[INFO]   Gitlab password: "

# kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d; echo
kubectl -n gitlab patch secret gitlab-gitlab-initial-root-password -p '{"stringData": {"admin.password": "$2a$12$HxOhjUJ3NQjMd3R4l4XGPO1LlCHuGjxu.vTBpf6SnegJdDIyvmCme", "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'


echo 'Waiting for gitlab to be deployed'
kubectl wait -n gitlab --for=condition=available deployment --all --timeout=-1s

kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8085:8181 | kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 