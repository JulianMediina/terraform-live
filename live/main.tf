# source y ref son literales a propósito: Terraform los resuelve en "init",
# antes de leer las .tfvars, así que no pueden depender de una variable. Los
# tres ambientes de esta misma carpeta comparten siempre la misma versión de
# módulo; para versiones distintas simultáneas haría falta carpeta por ambiente.
module "registry" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/ecr?ref=v0.2.0"

  repository_name = "${var.project}-${var.environment}-site"
  environment     = var.environment
  kms_key_arn     = data.aws_kms_alias.site.target_key_arn
  tags            = var.tags
}

module "service" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/ecs-express?ref=v0.2.0"

  environment    = var.environment
  repository_url = module.registry.repository_url
  kms_key_arn    = data.aws_kms_alias.site.target_key_arn
  cpu            = var.cpu
  memory         = var.memory
  min_task_count = var.min_task_count
  max_task_count = var.max_task_count
  tags           = var.tags
}

module "observability" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/observability?ref=v0.2.0"

  environment                  = var.environment
  cluster_name                 = module.service.cluster_name
  service_name                 = module.service.service_name
  notification_emails          = var.notification_emails
  cpu_utilization_threshold    = var.cpu_utilization_threshold
  memory_utilization_threshold = var.memory_utilization_threshold
  tags                         = var.tags
}
