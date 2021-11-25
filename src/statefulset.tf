locals {
  selector_labels = {
    "app.kubernetes.io/name": var.name
    # "app.kubernetes.io/instance": {{ .Release.Name }}
  }
}

# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }


// ref: https://github.com/codecentric/helm-charts/blob/master/charts/keycloak/templates/statefulset.yaml
resource "kubernetes_stateful_set" "keycloak" {
  metadata {
    name = var.name
    namespace = var.namespace
  }
  spec {
    replicas = var.replicas
    
    selector {
      match_labels = local.selector_labels
    }
    
    service_name = "${var.name}-headless"

    template {
      metadata {
        labels = local.selector_labels
      }

      spec {
        # image_pull_secrets {
        #   name = "some-secret-name"
        # }
        container {
          image = var.image
          name  = var.name
          # image_pull_policy = "Always"

          port {
            name = "http"
            container_port = 8080
            protocol = "TCP"
          }

          port {
            name = "https"
            container_port = 8443
            protocol = "TCP"
          }

          port {
            name = "http-management"
            container_port = 9990
            protocol = "TCP"
          }
          
          # resources {
          #   limits = {
          #     cpu    = "1000m"
          #     memory = "1500M"
          #   }
          #   requests = {
          #     cpu    = "100m"
          #     memory = "200M"
          #   }
          # }

          dynamic "env" {
            for_each = var.env
            iterator = each
            
            content {
              name = each.key
              value = each.value
            }
          }
        }
        
        # init_container {
          
        # }
      }
    }
  }
}

