# source y ref son literales a propósito: Terraform los resuelve en "init",
# antes de leer las .tfvars, así que no pueden depender de una variable. Los
# tres ambientes de esta misma carpeta comparten siempre la misma versión de
# módulo; para versiones distintas simultáneas haría falta carpeta por ambiente.
module "site_bucket" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/s3-site?ref=v0.1.5"

  bucket_name   = "${var.project}-${var.environment}-site"
  environment   = var.environment
  kms_key_arn   = data.aws_kms_alias.site.target_key_arn
  force_destroy = var.force_destroy_site_bucket
  tags          = var.tags
}

module "cdn" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/cloudfront-oac?ref=v0.1.5"

  environment                 = var.environment
  bucket_id                   = module.site_bucket.bucket_id
  bucket_arn                  = module.site_bucket.bucket_arn
  bucket_regional_domain_name = module.site_bucket.bucket_regional_domain_name
  price_class                 = var.price_class
  aliases                     = var.aliases
  acm_certificate_arn         = var.acm_certificate_arn
  tags                        = var.tags
}

module "observability" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/observability?ref=v0.1.5"

  environment                 = var.environment
  distribution_id             = module.cdn.distribution_id
  notification_emails         = var.notification_emails
  error_rate_threshold        = var.error_rate_threshold
  origin_latency_threshold_ms = var.origin_latency_threshold_ms
  tags                        = var.tags
}
