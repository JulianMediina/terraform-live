environment                 = "integracion"
price_class                 = "PriceClass_100"
force_destroy_site_bucket   = true
error_rate_threshold        = 10
origin_latency_threshold_ms = 3000

tags = {
  Project     = "daviplata"
  Environment = "integracion"
  CostCenter  = "devsecops-prueba"
  Owner       = "platform-team"
  ManagedVia  = "terraform"
  TestRun     = "rollback-verification-4"
}
