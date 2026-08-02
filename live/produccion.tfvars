environment                  = "produccion"
cpu                          = "256"
memory                       = "512"
min_task_count               = 1
max_task_count               = 2
cpu_utilization_threshold    = 80
memory_utilization_threshold = 80

# El ALB de ECS Express Mode es compartido por los 3 ambientes de la cuenta;
# la alarma de tiempo de respuesta se habilita solo aqui para no triplicar
# la misma alarma bajo 3 nombres de ambiente distintos (ver terraform-modules
# /modules/observability y docs/networking.md).
enable_response_time_alarm      = true
response_time_threshold_seconds = 2

tags = {
  Project     = "daviplata"
  Environment = "produccion"
  CostCenter  = "daviplata-platform"
  Owner       = "platform-team"
  ManagedVia  = "terraform"
}
