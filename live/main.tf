# source y ref son literales a propósito: Terraform los resuelve en "init",
# antes de leer las .tfvars, así que no pueden depender de una variable. Los
# tres ambientes de esta misma carpeta comparten siempre la misma versión de
# módulo; para versiones distintas simultáneas haría falta carpeta por ambiente.
module "registry" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/ecr?ref=v0.5.0"

  repository_name = "${var.project}-${var.environment}-site"
  environment     = var.environment
  kms_key_arn     = data.aws_kms_alias.site.target_key_arn
  tags            = var.tags
}

module "service" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/ecs-express?ref=v0.5.0"

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
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/observability?ref=v0.5.0"

  environment                     = var.environment
  cluster_name                    = module.service.cluster_name
  service_name                    = module.service.service_name
  notification_emails             = var.notification_emails
  cpu_utilization_threshold       = var.cpu_utilization_threshold
  memory_utilization_threshold    = var.memory_utilization_threshold
  enable_response_time_alarm      = var.enable_response_time_alarm
  response_time_threshold_seconds = var.response_time_threshold_seconds
  tags                            = var.tags
}

# Publica en SSM Parameter Store lo que daviplata-app necesita para su propio
# pipeline (build/push/deploy), en vez de que alguien lo copie a mano como
# variables de GitHub en el otro repo. El pipeline de la app lo lee por
# convención de ruta (/daviplata/<ambiente>/...) con el mismo rol OIDC que ya
# usa para todo lo demás.
module "parameters" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/ssm-publish?ref=v0.5.0"

  path_prefix = "/${var.project}/${var.environment}"
  parameters = {
    "ecr/repository-url"   = module.registry.repository_url
    "ecs/cluster-name"     = module.service.cluster_name
    "ecs/service-name"     = module.service.service_name
    "ecs/service-arn"      = module.service.service_arn
    "ecs/service-endpoint" = module.service.service_endpoint
    "sns/topic-arn"        = module.observability.sns_topic_arn
  }
  tags = var.tags
}
