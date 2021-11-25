# Usage

After starting the dev container:

1. run the following commands (in devcontainer):

```bash
minikube start --kubernetes-version=v1.21.6
minikube addons enable ingress
minikube ip # take note of the minikube ip for later step
pushd tests
terraform init
terraform apply -auto-approve
```

2. forward ip to host machine

- run vs code command "Forward a Port"
- input `192.186.49.2:80` (replace the ip with the one obtained from `minikube ip`)
- take note of localhost port

3. edit `/etc/hosts` (in host machine)

-  add `127.0.0.1 keycloak.example.com`

4. navigate to keycloak page (in host machine)

- open `keycloak.example.com:<port>` (where port is the forwarded port in step 2)