variable "name" {
  type    = string
  default = "keycloak"
}

variable "image" {
  type    = string
  default = "docker.io/jboss/keycloak:latest"
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "replicas" {
  type    = number
  default = 1
}

variable "ingress" {
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
  type    = map(string)
  default = {}
}

variable "startup_scripts" {
  type    = map(string)
  default = {}
}
