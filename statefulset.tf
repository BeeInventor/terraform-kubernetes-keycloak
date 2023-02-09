

// ref: https://github.com/codecentric/helm-charts/blob/master/charts/keycloak/templates/statefulset.yaml
resource "kubernetes_stateful_set_v1" "keycloak" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas     = var.autoscaling == null ? var.replicas : null
    service_name = kubernetes_service_v1.headless.metadata[0].name

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

          startup_probe {
            http_get {
              path = "/health"
              port = 9990
            }

            initial_delay_seconds = 60 # wait for a minute before the first probe (it is slow)
            period_seconds        = 20 # try every 20s
            failure_threshold     = 30 # try 30 times
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 9990
            }

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

          env {
            # note: this enables the /metrics endpoint, it also makes the management endpoint bind to 0.0.0.0 thus allow probing the /health endpoint
            # see: https://github.com/keycloak/keycloak-containers/blob/5df2de0500983e7424b321cca83a02c31da18fb3/server/tools/docker-entrypoint.sh#L94-L96
            name  = "KEYCLOAK_STATISTICS"
            value = "all"
          }
        }

        volume {
          name = local.startup_scripts.volume_name
          config_map {
            name         = kubernetes_config_map_v1.startup.metadata[0].name
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

        dynamic "affinity" {
          for_each = length(var.affinity_required_node_labels) > 0 ? [1] : []
          content {
            node_affinity {
              required_during_scheduling_ignored_during_execution {
                node_selector_term {
                  dynamic "match_expressions" {
                    for_each = toset(var.affinity_required_node_labels)
                    content {
                      key      = match_expressions.key.key
                      operator = match_expressions.key.operator
                      values   = match_expressions.key.values
                    }
                  }
                }
              }
            }
          }
        }

      }
    }
  }
}

resource "kubernetes_pod_disruption_budget_v1" "main" {
  count = var.autoscaling != null || var.replicas > 1 ? 1 : 0
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    min_available = 1
    selector {
      match_labels = local.selector_labels
    }
  }
}
