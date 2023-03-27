#! /bin/bash

pushd ./management-app/minikube

minikube start
minikube addons enable ingress
kubectl apply -f ./k8s.yaml
kubectl apply -f ./config.yaml

popd