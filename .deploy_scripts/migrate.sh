echo "${KUBE_CONFIG_DATA}" | base64 -d > kubeconfig
export KUBECONFIG=kubeconfig

kubectl create -f .k8s/jobs/migrate.yml
kubectl wait --for=condition=complete --timeout=600s job/migrate
kubectl delete job migrate
