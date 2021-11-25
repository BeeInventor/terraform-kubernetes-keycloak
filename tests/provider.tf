
provider "kubernetes" {
  config_paths           = ["~/.kube/config"]
  config_context         = "minikube"
}