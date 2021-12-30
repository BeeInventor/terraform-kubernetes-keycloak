

// ref: https://github.com/codecentric/helm-charts/blob/master/charts/keycloak/templates/statefulset.yaml
resource "kubernetes_stateful_set" "keycloak" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas     = var.autoscaling == null ? var.replicas : null
    service_name = kubernetes_service.headless.metadata[0].name

    selector {
      match_labels = local.selector_labels
    }

    template {
      metadata {
        labels = local.selector_labels
      }

      spec {
        # image_pull_secrets {
        #   name = "some-secret-name"
        # }
        container {
          name  = var.name
          image = var.image
          # image_pull_policy = "Always"

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          port {
            name           = "https"
            container_port = 8443
            protocol       = "TCP"
          }

          port {
            name           = "http-management"
            container_port = 9990
            protocol       = "TCP"
          }

          dynamic "volume_mount" {
            for_each = local.startup_scripts.entries
            iterator = each

            content {
              name       = local.startup_scripts.volume_name
              mount_path = "/opt/jboss/startup-scripts/${each.key}"
              sub_path   = each.key
              read_only  = true
            }
          }

          resources {
            limits   = try(var.resources.limits, null)
            requests = try(var.resources.requests, null)
          }

          dynamic "env" {
            for_each = var.env
            iterator = each

            content {
              name  = each.key
              value = each.value
            }
          }

          env {
            name  = "PROXY_ADDRESS_FORWARDING"
            value = "true"
          }

          env {
            name  = "JGROUPS_DISCOVERY_PROTOCOL"
            value = "kubernetes.KUBE_PING"
          }

          env {
            name  = "KUBERNETES_NAMESPACE"
            value = var.namespace
          }

          env {
            name  = "CACHE_OWNERS_COUNT"
            value = "2"
          }

          env {
            name  = "CACHE_OWNERS_AUTH_SESSIONS_COUNT"
            value = "2"
          }
        }

        volume {
          name = local.startup_scripts.volume_name
          config_map {
            name         = kubernetes_config_map.startup.metadata[0].name
            default_mode = "0555" # 5 = rx
            # dynamic "items" {
            #   for_each = local.startup_scripts.entries
            #   iterator = each
            #   content = {
            #     key = each.key
            #     path = each.key
            #   }
            # }
          }
        }
      }
    }
  }
}

