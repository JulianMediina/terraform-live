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

variable "price_class" {
  description = "Price class de CloudFront para este ambiente."
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "Dominios propios de la distribución (vacío = dominio por defecto de CloudFront)."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM en us-east-1, si se usan aliases."
  type        = string
  default     = null
}

variable "force_destroy_site_bucket" {
  description = "Permite destruir el bucket del sitio con objetos dentro. Solo true en ambientes no productivos."
  type        = bool
  default     = false
}

variable "notification_emails" {
  description = "Correos suscritos a las alarmas de este ambiente. Sin default a propósito: se pasa por TF_VAR_notification_emails desde un secret de GitHub, nunca committeado en texto plano en un .tfvars público."
  type        = list(string)
}

variable "error_rate_threshold" {
  description = "Umbral (%) de tasa de error que dispara la alarma."
  type        = number
  default     = 5
}

variable "origin_latency_threshold_ms" {
  description = "Umbral de latencia de origen (ms) que dispara la alarma."
  type        = number
  default     = 2000
}

variable "tags" {
  description = "Tags comunes aplicados a todos los recursos del ambiente."
  type        = map(string)
  default     = {}
}
