# output "headless_service" {
#   value = kubernetes_service.headless.metadata[0]
# }
output "http_service" {
  value = kubernetes_service.http.metadata[0]
  description = "Metadata of Keycloak HTTP service. Use this to configure your ingress."
}