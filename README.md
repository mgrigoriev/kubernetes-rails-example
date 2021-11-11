# Rails → Kubernetes, using GitHub Actions

Rails app for experiments with deployment to Kubernetes cluster.

If you are going to use it for some purpose, please replace `mgrigoriev/kubernetes-rails-example`
with a name of your docker image in all configuration files. 

### Configuration files

* [Kubernetes](/.k8s)
* [GitHub Actions](/.github/workflows/deploy.yml)
* [Scripts](/.deploy_scripts)
* [Dockerfile](/Dockerfile)

### K8s cluster setup

```
cd ~/.kube

# Add "do.yaml" config to existing "config" file
export KUBECONFIG=config:do.yaml

# See contexts for all clusters
kubectl config get-contexts

# Set current context
kubectl config use-context <context-name>

# Check if we are in the right context
kubectl get nodes

# Apply manifests
kubectl apply -R -f /path/to/app/.k8s/

# Create secret for pulling image from Docker registry
kubectl create secret docker-registry regcred --docker-server=registry-server> \
                                              --docker-username=<username> \
                                              --docker-password=<password> \
                                              --docker-email=<email>

# Create secrets for access to external database and redis server
kubectl create secret generic env --from-literal=DATABASE_URL=postgres://<user>:<pass>@<ip>:5432/<dbname> \
                                  --from-literal=REDIS_URL=redis://<ip>:6379/0
```

### GitHub setup

Create secrets required for GitHub Actions:

* DOCKERHUB_USERNAME
* DOCKERHUB_TOKEN
* KUBE_CONFIG_DATA

Run this command to get a value for KUBE_CONFIG_DATA:
```
cat $HOME/.kube/<cluster-config> | base64
```

### Notes for Minikube

1) Use `host.minikube.internal` instead of ip address in `DATABASE_URL` and `REDIS_URL`
when Postgres and redis are running on a host machine.

2. Minikube requires manual action for load balancer service. After applying k8s manifests, run this command:
    ```
    minikube service kubernetes-rails-example-load-balancer -n <your-namespace>
    ```

### Useful links

* [Dockerize Rails, the lean way](https://ledermann.dev/blog/2018/04/19/dockerize-rails-the-lean-way/)
* [Deploying a Rails application to Kubernetes](https://kubernetes-rails.com/)
