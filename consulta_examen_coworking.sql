-- =====================================================================
--  EXAMEN DE CARLOS MARIO VELASQUEZ ANGULO GRUPO:5 - SISTEMA DE COWORKING  (base de datos: coworking_grupo5)
--  MySQL(usa CTE / clausula WITH)
--
--  ENUNCIADO
--  Mostrar el nombre del usuario, el tipo de membresia y el total pagado
--  por reservas de los usuarios con membresia ACTIVA, solo si ese total
--  es mayor a 100 (dolares, moneda de los registros), ordenado de mayor
--  a menor total pagado.
-- =====================================================================
USE coworking_grupo5;

-- ---------------------------------------------------------------------
--  LOGICA GENERAL
--  El modelo no relaciona 'pagos' con 'reservas' directamente. El camino es:
--
--      reservas <- detalles_venta -> ventas <- pagos
--
--  * detalles_venta (concepto = 'RESERVA') indica que una reserva fue cobrada
--    dentro de una venta.
--  * pagos guarda cuanto se pago por esa venta (monto incluye IVA 19 %).
--  * ventas.id_usuario dice que usuario realizo la compra.
--
--  Para no duplicar montos, se calcula cada dato por separado (3 CTE)
--  y luego se unen en la consulta final.
-- ---------------------------------------------------------------------
WITH

-- PASO 1: ventas que contienen al menos una RESERVA real.
--   DISTINCT evita contar dos veces una venta con varias reservas, lo que
--   multiplicaria sus pagos al unirse con la tabla pagos.
--   Se excluyen PENALIZACION (cargo por no-show), SERVICIO y MEMBRESIA.
ventas_con_reserva AS (
    SELECT DISTINCT d.id_venta
    FROM detalles_venta d
    JOIN reservas r ON r.id_reserva = d.id_reserva
    WHERE d.concepto = 'RESERVA'
),

-- PASO 2: total pagado por reservas de cada usuario.
--   * Solo pagos en estado PAGADO (se ignoran PENDIENTE y CANCELADO).
--   * Solo ventas hechas por un usuario (id_usuario no nulo); las ventas
--     de empresas se facturan a la empresa, no al usuario.
--   * Se agrupa por usuario ANTES de unir con membresias, para que si un
--     usuario tiene dos suscripciones activas su total no se duplique.
pagado_reservas_por_usuario AS (
    SELECT v.id_usuario,
           SUM(pg.monto) AS total_pagado_reservas
    FROM ventas v
    JOIN ventas_con_reserva vr ON vr.id_venta = v.id_venta
    JOIN pagos pg ON pg.id_venta = v.id_venta AND pg.estado   = 'PAGADO'
    WHERE v.id_usuario IS NOT NULL
    GROUP BY v.id_usuario
),

-- PASO 3: tipo de membresia de los usuarios con suscripcion ACTIVA.
--   DISTINCT evita filas repetidas cuando una persona tiene dos
--   suscripciones activas del mismo tipo (renovacion anticipada).
membresia_activa AS (
    SELECT DISTINCT s.id_usuario,
                    m.tipo_membresia
    FROM suscripciones s
    JOIN membresias m ON m.id_membresia = s.id_membresia
    WHERE s.estado = 'ACTIVA'
)

-- CONSULTA FINAL: une usuario + persona (nombre) + membresia + total pagado.
SELECT CONCAT_WS(' ', p.primer_nombre, p.segundo_nombre,
                      p.primer_apellido, p.segundo_apellido) AS nombre_usuario,
       ma.tipo_membresia,
       ROUND(pr.total_pagado_reservas, 2) AS total_pagado_reservas_usd
FROM usuarios u
JOIN personas p ON p.id_persona = u.id_persona
JOIN membresia_activa ma ON ma.id_usuario = u.id_usuario  
JOIN pagado_reservas_por_usuario pr ON pr.id_usuario = u.id_usuario    
WHERE pr.total_pagado_reservas > 100                                       
ORDER BY pr.total_pagado_reservas DESC;
