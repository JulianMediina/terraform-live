variable "environment" {
  description = "Ambiente que se está desplegando."
  type        = string

  validation {
    condition     = contains(["integracion", "laboratorio", "produccion"], var.environment)
    error_message = "environment debe ser integracion, laboratorio o produccion."
  }
}

variable "project" {
  description = "Nombre corto del proyecto, usado como prefijo de recursos."
  type        = string
  default     = "daviplata"
}

variable "region" {
  description = "Región AWS donde se despliega la infraestructura."
  type        = string
  default     = "us-east-1"
}

variable "cpu" {
  description = "CPU de la tarea Fargate, en unidades ECS (\"256\" = 0.25 vCPU)."
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memoria de la tarea Fargate, en MB."
  type        = string
  default     = "512"
}

variable "min_task_count" {
  description = "Número mínimo de tareas activas del servicio."
  type        = number
  default     = 1
}

variable "max_task_count" {
  description = "Número máximo de tareas activas del servicio."
  type        = number
  default     = 3
}

variable "notification_emails" {
  description = "Correos suscritos a las alarmas de este ambiente. Sin default a propósito: se pasa por TF_VAR_notification_emails desde un secret de GitHub, nunca committeado en texto plano en un .tfvars público."
  type        = list(string)
}

variable "cpu_utilization_threshold" {
  description = "Umbral (%) de uso de CPU que dispara la alarma."
  type        = number
  default     = 80
}

variable "memory_utilization_threshold" {
  description = "Umbral (%) de uso de memoria que dispara la alarma."
  type        = number
  default     = 80
}

variable "enable_response_time_alarm" {
  description = "Habilita la alarma de tiempo de respuesta del ALB compartido. El ALB de ECS Express Mode es único por cuenta y lo comparten los 3 ambientes -normalmente se habilita en uno solo (produccion) para no triplicar la misma alarma bajo 3 nombres de ambiente distintos. Ver terraform-modules/modules/observability."
  type        = bool
  default     = false
}

variable "response_time_threshold_seconds" {
  description = "Umbral (segundos) de tiempo de respuesta que dispara la alarma, si está habilitada."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags comunes aplicados a todos los recursos del ambiente."
  type        = map(string)
  default     = {}
}
