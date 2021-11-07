echo "${KUBE_CONFIG_DATA}" | base64 -d > kubeconfig
export KUBECONFIG=kubeconfig

kubectl rollout restart deployment/rails-app
kubectl rollout restart deployment/sidekiq
