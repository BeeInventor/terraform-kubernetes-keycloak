resource "kubernetes_config_map_v1" "startup" {
  metadata {
    name      = "${var.name}-startup"
    namespace = var.namespace
  }

  data = local.startup_scripts.entries
}
