# Keycloak in Kubernetes as a Terraform Module

This repo contains a Terraform module which manage a keycloak deployment inside kubernetes.
- Keycloak itself is deployed as a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/).
- Autoscaling can be optionally enabled.
- Support custom startup scripts

## Usage

```hcl
module "keycloak" {
  source = "github.com/BeeInventor/terraform-kubernetes-keycloak"

  # image     = "mihaibob/keycloak:15.0.1"
  namespace = local.namespace

  ## Hardcode number of replicas. Ignored when autoscaling is enabled.
  replicas = 3
  
  ## Enable autoscaling
  # autoscaling = {
  #   min_replicas = 3
  #   max_replicas = 10
  # }

  env = {
    DB_VENDOR   = "postgres"
    DB_ADDR     = ""
    DB_PORT     = ""
    DB_DATABASE = ""
    DB_USER     = ""
    DB_PASSWORD = ""

    KEYCLOAK_USER            = "admin"
    KEYCLOAK_PASSWORD        = "admin"
  }

  ## Extra startup scripts
  # startup_scripts = {
  #   "test.sh" = "#!/bin/sh\necho 'Hello from my custom startup script!'"
  # }
}
```


## Development

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

## References

- Keycloak Helm Chart: https://github.com/codecentric/helm-charts/tree/master/charts/keycloak