#!/bin/bash

sudo kubectl apply -f /vagrant/confs/app-configmap.yaml
sudo kubectl apply -f /vagrant/confs/app-deployment.yaml
sudo kubectl apply -f /vagrant/confs/app-service.yaml
sudo kubectl apply -f /vagrant/confs/app-ingress.yaml
