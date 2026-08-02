# terraform-live

Infraestructura por ambiente de la plataforma DaviPlata. Este repo **no declara recursos propios**: `live/` solo compone módulos publicados en [`terraform-modules`](https://github.com/JulianMediina/terraform-modules), fijados por tag (`?ref=vX.Y.Z`).

> Nota sobre la guía original: una versión anterior del documento de referencia mencionaba una carpeta `global/bootstrap/` dentro de este repo. Esa responsabilidad se consolidó por completo en el repo `terraform-foundation` (repo independiente, con su propio backend remoto y sus propios workflows) para respetar la separación de responsabilidades — aquí no existe.

## Una sola carpeta de código, tres ramas de ambiente

`live/` es la única raíz de código; **no se duplica** por ambiente. Lo que sí es distinto por ambiente son los valores (`*.tfvars`), la clave de estado remoto (`*.s3.tfbackend`) — y, con el modelo de ramas, **la rama donde vive el commit desplegado**:

| Ambiente | Rama | tfvars |
|---|---|---|
| Integración | `integracion` | `live/integracion.tfvars` |
| Laboratorio | `laboratorio` | `live/laboratorio.tfvars` |
| Producción | `main` | `live/produccion.tfvars` |

`main.tf`, `variables.tf`, `outputs.tf` son compartidos entre las tres ramas (viajan intactos en cada promoción). `source` y `version` de cada módulo son **literales** (Terraform los resuelve en `init`, antes de leer `.tfvars`), así que los tres ambientes usan siempre la misma versión de módulo.

## Flujo de ramas (branch-per-environment)

```
feature/algo → PR → integracion → PR → laboratorio → PR → main (producción)
```

- **Todo cambio nace en una rama `feature/*` (o `fix/*`) contra `integracion`** — nunca directo a `integracion`, `laboratorio` o `main`.
- **La promoción entre ambientes es un PR entre ramas de ambiente** (`integracion`→`laboratorio`, `laboratorio`→`main`), revisado igual que cualquier otro PR — con el plan comentado automáticamente antes de aprobar.
- El **mismo commit** avanza de rama en rama sin reescribirse: los workflows de apply no disparan con `push` a la rama, sino con el cierre del PR (`pull_request: types: [closed]`, `if: merged == true`), y usan `github.event.pull_request.head.sha` como referencia exacta — así el commit que se aplica es siempre el que se revisó, sin importar si GitHub usó "merge commit", "squash" o "rebase" para cerrar el PR.

## Backend remoto por ambiente

Cada `*.s3.tfbackend` apunta a un bucket de estado y una tabla de lock **exclusivos** de ese ambiente (creados por `terraform-foundation`). El pipeline asume el rol OIDC (`gha-<ambiente>`) correspondiente — el rol de integración no tiene permisos sobre el estado ni los recursos de producción.

## Qué compone `live/main.tf`

- `module.registry` → `ecr`
- `module.service` → `ecs-express`
- `module.observability` → `observability`

La llave KMS del repositorio ECR no se pasa por variable manual: `data.aws_kms_alias.site` la resuelve por convención de nombre (`alias/daviplata-site-<ambiente>`), evitando hardcodear ARNs que cambian entre cuentas.

## Arquitectura del sitio

El sitio se sirve como un contenedor sobre Amazon ECS Express Mode (Fargate + Application Load Balancer + auto-scaling en un solo recurso), no como bucket S3 detrás de CloudFront. `daviplata-app` publica la imagen en el repositorio ECR de cada ambiente; `service_endpoint` expone la URL pública HTTPS del servicio.

## GitOps

- **Plan en PR:** un único `plan.yml` corre `terraform plan` en cualquier PR que apunte a `integracion`/`laboratorio`/`main`, y comenta el resultado — nadie hace `plan` desde su laptop. El ambiente se resuelve de la rama base del PR (`github.base_ref`), así que no hay tres copias del mismo archivo por mantener.
- **Apply al mergear:** un único `apply.yml`, mismo patrón, dispara con `pull_request: types: [closed]` sobre las tres ramas; laboratorio y producción están protegidos por reglas de aprobación de GitHub Environments (Settings → Environments). Como el ambiente es dinámico, el gate de aprobación de cada ambiente se resuelve en tiempo de ejecución — el job de un PR contra `laboratorio` pide aprobación de `laboratorio`, uno contra `main` pide la de `produccion`.
- **Drift detection:** `drift-detection.yml` corre diario contra las tres ramas (`terraform plan -detailed-exitcode` sobre el código de cada una) y abre una incidencia si detecta divergencia.
- **Validación post-apply + rollback automático:** después de cada `apply` real, el mismo job vuelve a hacer `plan -detailed-exitcode` (confirma que quedó sin drift) y, en integración/laboratorio/producción, un smoke test del endpoint del servicio. Si cualquiera falla, restaura la configuración anterior y la re-aplica **en el mismo job** (sin pasar de nuevo por el gate de aprobación, porque ya está autorizado) y abre un PR de reversión para que el código quede consistente con lo desplegado. Nunca toca el `.tfstate` directamente. Notifica el resultado por correo (SNS) siempre.
- Nadie ejecuta `apply` ni `destroy` manualmente desde su máquina salvo en `terraform-foundation` (backend propio, ver su README).

## Comandos locales de referencia

```
make plan  ENV=integracion
make apply ENV=integracion
make drift ENV=integracion
make destroy ENV=integracion
```
