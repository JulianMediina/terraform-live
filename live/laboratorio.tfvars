environment                  = "laboratorio"
cpu                          = "256"
memory                       = "512"
min_task_count               = 1
max_task_count               = 2
cpu_utilization_threshold    = 80
memory_utilization_threshold = 80

# El ALB de ECS Express Mode es compartido por los 3 ambientes de la cuenta
# (ver docs/networking.md) -esta alarma mide el mismo balanceador que la de
# integracion y produccion, no un dato aislado de este ambiente.
enable_response_time_alarm      = true
response_time_threshold_seconds = 2

tags = {
  Project     = "daviplata"
  Environment = "laboratorio"
  CostCenter  = "daviplata-platform"
  Owner       = "platform-team"
  ManagedVia  = "terraform"
}
