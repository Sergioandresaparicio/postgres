# Taller Práctico de Bases de Datos

## 📊 Análisis de Planes de Ejecución
Al usar `EXPLAIN ANALYZE`, considerar:
* **Tipo de recorrido:** Identificar si se usa *Seq Scan*, *Index Scan* o *Bitmap Scan*.
* **Costo estimado:** Comparar antes y después de crear índices.
* **Tiempo real:** No evaluar optimización únicamente por tiempo de reloj.
* **Filas procesadas:** Verificar selectividad del índice.

## 🚀 Recomendaciones de Optimización
* **Alta selectividad:** Los índices son más efectivos cuando filtran un porcentaje reducido de filas (menos del 10-25%).
* **Índices compuestos:** La columna más restrictiva debe ir primero.
* **Proyección exacta:** Evitar `SELECT *` para reducir transferencia de datos.
* **ANALYZE:** Ejecutar después de crear índices para actualizar estadísticas.

## 🎯 Resultados Esperados
Al finalizar el taller, el estudiante será capaz de:
1. Escribir consultas SQL complejas con múltiples `JOIN`.
2. Interpretar planes de ejecución de PostgreSQL.
3. Identificar cuándo un índice mejora el rendimiento.
4. Justificar decisiones de optimización con métricas técnicas.
5. Aplicar buenas prácticas de consulta SQL.

## 🛠️ Tecnologías Utilizadas
* **PostgreSQL:** Sistema de gestión de bases de datos relacional.
* **pgAdmin:** Herramienta de administración gráfica para PostgreSQL.
* **SQL:** Lenguaje de consulta estructurado.
* **Markdown:** Formato de documentación.

## 👥 Integrantes
* Sergio Aparicio
* Jhon Reyes

## 📅 Información General
* **Fecha de Desarrollo:** 15 de septiembre de 2026
* **Duración Estimada:** 1 hora y 30 minutos

## 📜 Licencia
Este proyecto fue desarrollado con fines educativos como parte de un taller práctico de bases de datos.
