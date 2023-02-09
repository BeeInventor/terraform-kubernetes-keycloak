# output "headless_service" {
#   value = kubernetes_service_v1.headless.metadata[0]
# }
output "http_service" {
  value = kubernetes_service_v1.http.metadata[0]
  description = "Metadata of Keycloak HTTP service. Use this to configure your ingress."
}