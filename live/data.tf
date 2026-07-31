# Lookups de solo lectura hacia recursos creados por terraform-foundation.
# No son "resource": no rompen la regla de que live solo compone módulos.

data "aws_kms_alias" "site" {
  name = "alias/${var.project}-site-${var.environment}"
}
