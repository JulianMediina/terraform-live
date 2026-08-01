environment                 = "laboratorio"
price_class                 = "PriceClass_100"
force_destroy_site_bucket   = true
error_rate_threshold        = 5
origin_latency_threshold_ms = 2000

tags = {
  Project     = "daviplata"
  Environment = "laboratorio"
  CostCenter  = "devsecops-prueba"
  Owner       = "platform-team"
  ManagedVia  = "terraform"
}
