# Lotto

# TODO

- Registrar sorteos del dia siguiente [Programado por hora]
- Anexar impuesto sobre la venta, taquilla? banca? usuario?
- Anexar forma de pago en taquilla, reportes
- Mostrar responsable de la premiacion al notificar
- Verificar si la base de datos necesita mantenimiento, comprobar cantidad de registros o tamaño de base de datos

- [CM] Remover pago pendiente
- [SYS] No publicar todos los sorteos al cerrar/abrir sorteo manualmente
- [SYS] Mejorar el cierre de sorteos manual
- Habilitar la opción de múltiples porcentaje en comisión de ventas por productos para las Bancas y Grupos.
- Habilitar Gestor de pagos para control de cuentas en bancas y grupos.
- Habilitar auto premiacion

# 20.03.01

- Anexar el campo "impuesto" en el comando "--ventas" de "ventas.sql"

# 20.05.07

- Nuevo meta para las taquillas 'taquillas_meta.vnt_max_numtkt': limitar el numero maximo de jugadas por ticket

# 20.06.27

- [BN] Corregir notifcicaciones en caso que los datos de login recordados sean incorrectos
- [BN,GR] Habilitar reportes de ventas por productos para bancas y grupos
- NUEVO CAMPO usuarios.bancas: ALTER TABLE us.bancas ADD COLUMN participacion REAL
- Habilitar la opción de participación para los grupos.
- Mejoras en el reporte general y de sorteo para los grupos y bancas.

# 20.06.29

- SQL: NUEVO CAMPO SQL "relacion_pago"

# 20.07.01

- SQL: Nueva tabla autoPremiar
- NUEVO: nueva funcion para autopremiar sorteos

# 20.07.02

- CM: Comision grupo
- FIX: Error al enviar taquilla a papelera

# 20.07.13

- Cambio en config.json: "premios.bot"
    "bot": {
      "retraso": 300000,
      "ruletonperu": "UUID"
    }