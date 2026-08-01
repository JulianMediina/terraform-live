# Evidencia de rollback

`apply.yml` valida cada despliegue después de aplicarlo (sin drift + smoke test del dominio) y, si falla, restaura la configuración anterior automáticamente en el mismo run — sin pasar de nuevo por el gate de aprobación del ambiente — y abre un PR de reversión para que el código quede consistente con lo que realmente está desplegado. El mecanismo se documenta en detalle, con un caso real, en los archivos de esta carpeta.

A diferencia de `daviplata-app` (donde el rollback restaura un bundle ya construido), acá "revertir" significa volver a aplicar la configuración de Terraform anterior contra la infraestructura real — nunca se toca el `.tfstate` directamente.
