# Rollback automático — integración, 2026-08-01

Prueba real de punta a punta del mecanismo de validación post-apply + rollback automático de `apply.yml`, ejecutada contra la infraestructura real de integración (no un ambiente de prueba aparte). El objetivo no era solo confirmar que el mecanismo existe, sino ejercitarlo con una falla real y verificar en AWS que la restauración ocurrió de verdad.

## Cómo se forzó la falla

- Se agregó un tag trivial y real (`TestRun`) a `live/integracion.tfvars`, para tener un cambio genuino bajo `live/**` que disparara el pipeline.
- Se modificó temporalmente el paso "smoke test del dominio" en `apply.yml` para apuntar a un dominio inexistente (`this-domain-does-not-exist-rollback-test.invalid`) en vez del dominio real de CloudFront — garantiza una falla determinística sin tocar ningún recurso de infraestructura real.
- El resto del pipeline (apply real, validación de drift, lógica de rollback) corrió sin modificar — la única parte "falsa" fue el destino del smoke test.

## Bugs reales encontrados y corregidos

La prueba no pasó a la primera. Cada intento reveló un problema real, nunca antes ejercitado porque nunca antes se había disparado un rollback de verdad:

| # | Run | Error real | Causa | Fix |
|---|---|---|---|---|
| 1 | [30714297859](https://github.com/JulianMediina/terraform-live/actions/runs/30714297859) | `AccessDenied: ... cloudfront:UntagResource` | El rollback intentó *quitar* el tag de prueba; nunca antes se había quitado un tag, solo agregado/actualizado, así que ese permiso nunca se había otorgado a `gha-<ambiente>` | `terraform-foundation` PR [#14](https://github.com/JulianMediina/terraform-foundation/pull/14) — agrega `cloudfront:UntagResource` a `CloudFrontManage` |
| 2 | [30714297859](https://github.com/JulianMediina/terraform-live/actions/runs/30714297859) (rerun) → [30714839045](https://github.com/JulianMediina/terraform-live/actions/runs/30714839045) | `error: your local changes would be overwritten by revert` | El paso de rollback deja el working tree *y el índice* con la config anterior sin commitear (`git checkout <ref> -- .` también deja el índice modificado); `git checkout -- .` (sin ref) no lo deshace porque reconstruye desde ese mismo índice | PR [#21](https://github.com/JulianMediina/terraform-live/pull/21)/[#22](https://github.com/JulianMediina/terraform-live/pull/22) — cambia a `git reset --hard HEAD` |
| 3 | [30715123718](https://github.com/JulianMediina/terraform-live/actions/runs/30715123718) | `commit ... is a merge but no -m option was given` | La punta de `integracion` es casi siempre un commit de merge (todas las promociones usan "merge commit"); `git revert` sobre un merge exige indicar qué padre es la línea principal | PR [#23](https://github.com/JulianMediina/terraform-live/pull/23) — agrega `-m 1` |
| 4 | [30715322859](https://github.com/JulianMediina/terraform-live/actions/runs/30715322859) | `GraphQL: GitHub Actions is not permitted to create or approve pull requests` | Ajuste de repo desactivado por defecto: "Allow GitHub Actions to create and approve pull requests" | Habilitado vía API (`PUT .../actions/permissions/workflow`, `can_approve_pull_request_reviews: true`) en `terraform-live` y `terraform-foundation` |

## Corrida exitosa

Con los 4 fixes aplicados, el rerun de [30715322859](https://github.com/JulianMediina/terraform-live/actions/runs/30715322859) completó los 11 pasos en verde: apply → validación post-apply (detectó la falla) → smoke test (falló, como se esperaba) → rollback automático (re-aplicó la configuración anterior) → apertura del PR de reversión → notificación por correo.

Resultado: PR [#24](https://github.com/JulianMediina/terraform-live/pull/24) "Reversión automática: integracion falló la validación post-apply", creado por el propio pipeline, proponiendo revertir el tag de `rollback-verification-4` a `rollback-verification-3`.

## Verificación en AWS real (no solo en el log del pipeline)

Antes de dar por buena la prueba, se confirmó que la infraestructura real —no solo el plan— quedó restaurada:

```
$ aws s3api get-bucket-tagging --bucket daviplata-integracion-site --region us-east-1 \
    --query "TagSet[?Key=='TestRun']"
[
    {
        "Key": "TestRun",
        "Value": "rollback-verification-3"
    }
]
```

El valor real en AWS coincide exactamente con lo que el PR de reversión proponía en el código — confirma que el rollback restauró la infraestructura *antes* de que existiera ningún PR de reversión, sin esperar aprobación humana.

## Por qué el PR #24 se cerró sin mergear

El commit que disparó esta prueba mezclaba, en el mismo merge, el sabotage temporal del smoke test **y** el fix real de `-m 1`. El PR de reversión automático revierte el commit completo — mergearlo hubiera deshecho también el fix real. Se cerró con una nota explicando el motivo, y la limpieza final (retirar el sabotage, quitar el tag de prueba) se hizo en un PR aparte y limpio: [#25](https://github.com/JulianMediina/terraform-live/pull/25).

## Conclusión

El mecanismo de rollback automático funciona de punta a punta contra infraestructura real: detecta la falla, restaura sin intervención humana, dejó prueba verificable en AWS, y generó un PR de reversión para que el código no quede desincronizado — todo sin requerir ninguna aprobación adicional, tal como se diseñó. Los 4 problemas encontrados eran reales y específicos de este mecanismo (nunca antes ejercitado); quedan corregidos y ya promovidos a los 3 ambientes.
