# Backend parcial: bucket, key, region y tabla de lock se completan en init
# con -backend-config=<ambiente>.s3.tfbackend -reconfigure. Así los 3 ambientes
# comparten esta misma raíz sin duplicar código ni mezclar estados.
terraform {
  backend "s3" {}
}
