# 🏢 Examen - Sistema de Coworking (Consultas SQL)

Repositorio creado para la entrega del examen de bases de datos, implementando consultas SQL optimizadas sobre el modelo relacional de un sistema de coworking.

## 👤 Información del Estudiante
* **Nombre:** Carlos Mario Velasquez Angulo
* **Grupo:** 5
* **Base de Datos:** `coworking_grupo5`
* **Motor de Base de Datos:** MySQL 8.0

---

## 🎯 Objetivo y Enunciado

El objetivo principal es comprobar la capacidad de escribir consultas SQL complejas, limpias y correctas utilizando el modelo del sistema de coworking.

**Enunciado de la consulta:**
> Mostrar el nombre del usuario, el tipo de membresía y el total pagado por reservas de todos los usuarios que tengan una membresía **activa**, solo si ese total es **mayor a 100** (dólares, moneda de los registros), ordenado de mayor a menor total pagado.

---


### Estrategia de Solución (Uso de CTEs / Cláusula `WITH`)
Para evitar la multiplicación errónea de filas debido a las relaciones de uno a muchos, el script divide la lógica en **3 pasos modulares (CTE)** antes de unirlas en el reporte final:

1. **`ventas_con_reserva` (Paso 1):** Filtra las ventas que contienen al menos un concepto de tipo `'RESERVA'`, utilizando `DISTINCT` para evitar duplicados si una factura tiene múltiples reservas.
2. **`pagos_reservas_por_usuario` (Paso 2):** Suma el monto total de los pagos asociados a esas reservas (filtrando solo los que tienen estado `'PAGADO'` y excluyendo ventas corporativas mediante `IS NOT NULL`), agrupándolos por usuario antes de unirlos con las membresías.
3. **`membresia_activa` (Paso 3):** Identifica a los usuarios que poseen una suscripción con estado `'ACTIVA'` y su respectivo tipo de membresía.
4. **Consulta Final:** Une las tablas anteriores, procesa el nombre completo con `CONCAT_WS`, redondea los decimales con `ROUND`, aplica el filtro de valor mayor a 100 y ordena de forma descendente (`DESC`).

---

## 📂 Contenido del Repositorio

* `CONSULTA_EXAMEN_COWORKING.SQL`: Script principal que contiene toda la lógica explicada.

---

## 🚀 Instrucciones para Ejecutar el Script

1. Abre **MySQL Workbench**.
2. Asegúrate de tener seleccionada o importada la base de datos ejecutando:
   ```sql
   USE coworking_grupo5;
