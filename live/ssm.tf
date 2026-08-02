# Publica los valores de infraestructura que daviplata-app necesita para su
# propio pipeline (build/push/deploy) en SSM Parameter Store, en vez de que
# alguien los copie a mano como variables de GitHub en el otro repo. El
# pipeline de la app los lee por convención de ruta (/daviplata/<ambiente>/...)
# con el mismo rol OIDC que ya usa para todo lo demás.
resource "aws_ssm_parameter" "repository_url" {
  name  = "/${var.project}/${var.environment}/ecr/repository-url"
  type  = "String"
  value = module.registry.repository_url
  tags  = var.tags
}

resource "aws_ssm_parameter" "cluster_name" {
  name  = "/${var.project}/${var.environment}/ecs/cluster-name"
  type  = "String"
  value = module.service.cluster_name
  tags  = var.tags
}

resource "aws_ssm_parameter" "service_name" {
  name  = "/${var.project}/${var.environment}/ecs/service-name"
  type  = "String"
  value = module.service.service_name
  tags  = var.tags
}

resource "aws_ssm_parameter" "service_arn" {
  name  = "/${var.project}/${var.environment}/ecs/service-arn"
  type  = "String"
  value = module.service.service_arn
  tags  = var.tags
}

resource "aws_ssm_parameter" "service_endpoint" {
  name  = "/${var.project}/${var.environment}/ecs/service-endpoint"
  type  = "String"
  value = module.service.service_endpoint
  tags  = var.tags
}

resource "aws_ssm_parameter" "sns_topic_arn" {
  name  = "/${var.project}/${var.environment}/sns/topic-arn"
  type  = "String"
  value = module.observability.sns_topic_arn
  tags  = var.tags
}
