# TODO: allow config via variables
resource "kubernetes_role" "main" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "main" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.main.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.namespace
  }
}
