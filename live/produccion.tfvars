environment                 = "produccion"
price_class                 = "PriceClass_100"
force_destroy_site_bucket   = false
error_rate_threshold        = 5
origin_latency_threshold_ms = 1500

tags = {
  Project     = "daviplata"
  Environment = "produccion"
  CostCenter  = "devsecops-prueba"
  Owner       = "platform-team"
  ManagedVia  = "terraform"
}
