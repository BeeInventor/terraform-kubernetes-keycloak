variable "name" {
  description = "Base name for all the created resources"
  type        = string
  default     = "keycloak"
}

variable "image" {
  description = "Docker image for the Keycloak container"
  type        = string
  default     = "docker.io/jboss/keycloak:latest"
}

variable "namespace" {
  description = "Namespace to spawn all the resources"
  type        = string
  default     = "default"
}

variable "replicas" {
  description = "Number of replicas for Keycloak. Ignored when autoscaling is specified."
  type        = number
  default     = 1
}

variable "autoscaling" {
  description = "Enable auto-scaling via horizontal pod autoscaler"
  type = object({
    min_replicas = number
    max_replicas = number
  })
  default = null
}

variable "ingress" {
  description = "Ingress configurations"
  type = object({
    annotations = optional(map(string))
    # rules = array({
    # 	host = string
    # 	paths = array({
    # 		path = string
    # 		path_type = string
    # 	})
    # })
  })
  default = {}
}

variable "env" {
  description = "Environment variables for the Keycloak container"
  type        = map(string)
  default     = {}
}

variable "startup_scripts" {
  description = "Startup scripts to be run when the Keycloak container is initalized"
  type        = map(string)
  default     = {}
}
