output "service_account_name" {
  value       = kubernetes_service_account_v1.this.metadata[0].name
  description = "The name of the created Service Account"
}

output "secret_name" {
  value       = kubernetes_secret_v1.this.metadata[0].name
  description = "The name of the created Secret"
}
