environment                  = "laboratorio"
cpu                          = "256"
memory                       = "512"
min_task_count               = 1
max_task_count               = 2
cpu_utilization_threshold    = 80
memory_utilization_threshold = 80

tags = {
  Project     = "daviplata"
  Environment = "laboratorio"
  CostCenter  = "devsecops-prueba"
  Owner       = "platform-team"
  ManagedVia  = "terraform"
}
