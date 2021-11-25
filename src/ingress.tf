resource "kubernetes_ingress" "keycloak" {
  count = var.ingress == null ? 0 : 1

  metadata {
    name        = "${var.name}-http"
    namespace   = var.namespace
    annotations = var.ingress.annotations
  }

  spec {
    rule {
      host = "keycloak.example.com"
      http {
        path {
          backend {
            service_name = "${var.name}-http"
            service_port = 80
          }

          path = "/"
          # path_type = "Prefix"
        }
      }
    }
  }
}
