environment                 = "integracion"
price_class                 = "PriceClass_100"
force_destroy_site_bucket   = true
notification_emails         = ["julian.mediina@gmail.com"]
error_rate_threshold        = 10
origin_latency_threshold_ms = 3000

tags = {
  Project     = "daviplata"
  Environment = "integracion"
  CostCenter  = "devsecops-prueba"
  Owner       = "platform-team"
}
