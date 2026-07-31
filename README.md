# terraform-live

Infraestructura por ambiente de la plataforma DaviPlata. Este repo **no declara recursos propios**: `live/` solo compone módulos publicados en [`terraform-modules`](https://github.com/JulianMediina/terraform-modules), fijados por tag (`?ref=vX.Y.Z`).

> Nota sobre la guía original: una versión anterior del documento de referencia mencionaba una carpeta `global/bootstrap/` dentro de este repo. Esa responsabilidad se consolidó por completo en el repo `terraform-foundation` (repo independiente, estado local, ejecución única) para respetar la separación de responsabilidades del §0/§4.1 — aquí no existe.

## Una sola carpeta, tres ambientes

`live/` es la única raíz de código; **no se duplica** por ambiente. Lo que cambia por ambiente son los valores (`*.tfvars`) y la clave de estado remoto (`*.s3.tfbackend`):

```
terraform init  -backend-config=produccion.s3.tfbackend -reconfigure
terraform plan  -var-file=produccion.tfvars
terraform apply -var-file=produccion.tfvars
```

`main.tf`, `variables.tf`, `outputs.tf` son compartidos. `source` y `version` de cada módulo son **literales** (Terraform los resuelve en `init`, antes de leer `.tfvars`), así que los tres ambientes usan siempre la misma versión de módulo.

## Backend remoto por ambiente

Cada `*.s3.tfbackend` apunta a un bucket de estado y una tabla de lock **exclusivos** de ese ambiente (creados por `terraform-foundation`). El pipeline asume el rol OIDC (`gha-<ambiente>`) correspondiente — el rol de integración no tiene permisos sobre el estado ni los recursos de producción.

## Qué compone `live/main.tf`

- `module.site_bucket` → `s3-site`
- `module.cdn` → `cloudfront-oac`
- `module.observability` → `observability`

La llave KMS del bucket de sitio no se pasa por variable manual: `data.aws_kms_alias.site` la resuelve por convención de nombre (`alias/daviplata-site-<ambiente>`), evitando hardcodear ARNs que cambian entre cuentas.

## GitOps

- **Plan en PR:** `infra-plan.yml` corre `terraform plan` para los tres ambientes en cada PR que toque `live/**` y comenta el resultado — nadie hace `plan` desde su laptop.
- **Apply al merge:** `infra-apply.yml` aplica en orden `integracion → laboratorio → producción`; laboratorio y producción están protegidos por reglas de aprobación de GitHub Environments (Settings → Environments).
- **Drift detection:** `drift-detection.yml` corre diario (`terraform plan -detailed-exitcode`) y abre una incidencia si detecta divergencia.
- Nadie ejecuta `apply` ni `destroy` manualmente desde su máquina salvo en `terraform-foundation` (bootstrap único) o en cierres de ambientes de prueba documentados en el runbook.

## Comandos locales de referencia

```
make plan  ENV=integracion
make apply ENV=integracion
make drift ENV=integracion
make destroy ENV=integracion
```
