environment                  = "produccion"
cpu                          = "512"
memory                       = "1024"
min_task_count               = 1
max_task_count               = 3
cpu_utilization_threshold    = 75
memory_utilization_threshold = 75

tags = {
  Project     = "daviplata"
  Environment = "produccion"
  CostCenter  = "devsecops-prueba"
  Owner       = "platform-team"
  ManagedVia  = "terraform"
}
