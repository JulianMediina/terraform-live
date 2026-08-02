output "repository_url" {
  description = "URL del repositorio ECR, usado por el pipeline de despliegue para publicar imágenes."
  value       = module.registry.repository_url
}

output "cluster_name" {
  description = "Nombre del cluster ECS, usado por el pipeline de despliegue."
  value       = module.service.cluster_name
}

output "service_name" {
  description = "Nombre del servicio ECS Express, usado por el pipeline de despliegue para actualizar la imagen."
  value       = module.service.service_name
}

output "service_endpoint" {
  description = "URL pública HTTPS del ambiente."
  value       = module.service.service_endpoint
}

output "sns_topic_arn" {
  description = "ARN del tópico SNS de alarmas de este ambiente."
  value       = module.observability.sns_topic_arn
}
