#!/bin/sh -ex

# export KUBECONFIG=~/.kube/kubernetes-rails-example-kubeconfig.yaml

docker build -t mgrigoriev/kubernetes-rails-example:latest .
docker push mgrigoriev/kubernetes-rails-example:latest

kubectl create -f .k8s/jobs/migrate.yml
kubectl wait --for=condition=complete --timeout=600s job/migrate
kubectl delete job migrate

kubectl rollout restart deployment/rails-app
kubectl rollout restart deployment/sidekiq
