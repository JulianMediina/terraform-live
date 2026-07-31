output "bucket_id" {
  description = "Nombre del bucket del sitio, usado por el pipeline de despliegue."
  value       = module.site_bucket.bucket_id
}

output "distribution_id" {
  description = "ID de la distribución CloudFront, usado para invalidaciones."
  value       = module.cdn.distribution_id
}

output "distribution_domain_name" {
  description = "Dominio público del ambiente."
  value       = module.cdn.distribution_domain_name
}

output "sns_topic_arn" {
  description = "ARN del tópico SNS de alarmas de este ambiente."
  value       = module.observability.sns_topic_arn
}
