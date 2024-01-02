#!/bin/bash

sudo kubectl apply -f ../confs/app-configmap.yaml
sudo kubectl apply -f ../confs/app-deployment.yaml
sudo kubectl apply -f ../confs/app-service.yaml
sudo kubectl apply -f ../confs/app-ingress.yaml
