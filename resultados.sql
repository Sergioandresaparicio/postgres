-- =============================================================================
-- TALLER: CONSULTAS Y OPTIMIZACIÓN EN POSTGRESQL CON CHINOOK
-- SCRIPT ENTREGABLE CONSOLIDADO
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ETAPA 1: RECONOCIMIENTO Y CONTEO
-- -----------------------------------------------------------------------------

-- Exploración de tablas (primeros 10 registros)
SELECT * FROM public."Artist" LIMIT 10;
SELECT * FROM public."Album" LIMIT 10;
SELECT * FROM public."Track" LIMIT 10;
SELECT * FROM public."Customer" LIMIT 10;
SELECT * FROM public."Invoice" LIMIT 10;
SELECT * FROM public."InvoiceLine" LIMIT 10;

-- Conteo de registros por tabla
SELECT 'Artist' AS tabla, COUNT(*) AS total FROM public."Artist"
UNION ALL
SELECT 'Album', COUNT(*) FROM public."Album"
UNION ALL
SELECT 'Track', COUNT(*) FROM public."Track"
UNION ALL
SELECT 'Customer', COUNT(*) FROM public."Customer"
UNION ALL
SELECT 'Invoice', COUNT(*) FROM public."Invoice"
UNION ALL
SELECT 'InvoiceLine', COUNT(*) FROM public."InvoiceLine"
UNION ALL
SELECT 'Genre', COUNT(*) FROM public."Genre"
UNION ALL
SELECT 'MediaType', COUNT(*) FROM public."MediaType"
UNION ALL
SELECT 'Employee', COUNT(*) FROM public."Employee"
UNION ALL
SELECT 'Playlist', COUNT(*) FROM public."Playlist"
UNION ALL
SELECT 'PlaylistTrack', COUNT(*) FROM public."PlaylistTrack";

-- -----------------------------------------------------------------------------
-- ETAPA 2: CONSULTAS BÁSICAS (EJERCICIOS 1 AL 6)
-- -----------------------------------------------------------------------------

-- Ejercicio 1: Filtros y ordenamiento (canciones >= 1.00)
SELECT 
    "TrackId",
    "Name",
    "UnitPrice"
FROM public."Track"
WHERE "UnitPrice" >= 1.00
ORDER BY "UnitPrice" DESC, "Name" ASC;

-- Ejercicio 2: Búsqueda de clientes (Brasil, Canadá, USA)
SELECT 
    "FirstName" || ' ' || "LastName" AS "NombreCompleto",
    "Country",
    "City",
    "Email"
FROM public."Customer"
WHERE "Country" IN ('Brazil', 'Canada', 'USA')
ORDER BY "Country" ASC, "NombreCompleto" ASC;

-- Ejercicio 3: Búsqueda de canciones (contengan 'Love' sin importar mayúsculas)
SELECT 
    "TrackId",
    "Name",
    "Composer",
    "UnitPrice"
FROM public."Track"
WHERE "Name" ILIKE '%love%'
ORDER BY "Name" ASC;

-- Ejercicio 4: Funciones de agregación
SELECT 
    COUNT(*) AS total_canciones,
    ROUND(AVG("UnitPrice")::numeric, 2) AS precio_promedio,
    MIN("UnitPrice") AS precio_minimo,
    MAX("UnitPrice") AS precio_maximo,
    ROUND(AVG("Milliseconds")::numeric, 2) AS duracion_promedio_ms
FROM public."Track";

-- Ejercicio 5: Agrupación (clientes por país)
SELECT 
    "Country" AS pais,
    COUNT(*) AS cantidad_clientes
FROM public."Customer"
GROUP BY "Country"
ORDER BY cantidad_clientes DESC, pais ASC;

-- Ejercicio 6: Condición sobre agrupaciones (al menos 2 clientes)
SELECT 
    "Country" AS pais,
    COUNT(*) AS cantidad_clientes
FROM public."Customer"
GROUP BY "Country"
HAVING COUNT(*) >= 2
ORDER BY cantidad_clientes DESC, pais ASC;

-- -----------------------------------------------------------------------------
-- ETAPA 3: CONSULTAS CON JOIN (EJERCICIOS 7 AL 12)
-- -----------------------------------------------------------------------------

-- Ejercicio 7: Álbumes y artistas
SELECT 
    al."AlbumId",
    al."Title" AS album,
    ar."Name" AS artista
FROM public."Album" al
INNER JOIN public."Artist" ar ON al."ArtistId" = ar."ArtistId"
ORDER BY ar."Name" ASC, al."Title" ASC;

-- Ejercicio 8: Canciones, álbumes y artistas con duración en minutos
SELECT 
    t."Name" AS cancion,
    al."Title" AS album,
    ar."Name" AS artista,
    t."UnitPrice" AS precio,
    ROUND((t."Milliseconds" / 60000.0)::numeric, 2) AS duracion_minutos
FROM public."Track" t
INNER JOIN public."Album" al ON t."AlbumId" = al."AlbumId"
INNER JOIN public."Artist" ar ON al."ArtistId" = ar."ArtistId"
ORDER BY ar."Name" ASC, al."Title" ASC, t."Name" ASC;

-- Ejercicio 9: Clientes y facturas
SELECT 
    i."InvoiceId" AS numero_factura,
    c."FirstName" || ' ' || c."LastName" AS nombre_completo,
    c."Country" AS pais,
    i."InvoiceDate" AS fecha,
    i."Total" AS total
FROM public."Invoice" i
INNER JOIN public."Customer" c ON i."CustomerId" = c."CustomerId"
ORDER BY i."InvoiceDate" DESC;

-- Ejercicio 10: Detalle completo de ventas
SELECT 
    c."FirstName" || ' ' || c."LastName" AS cliente,
    i."InvoiceId" AS numero_factura,
    t."Name" AS cancion,
    il."UnitPrice" AS precio_unitario,
    il."Quantity" AS cantidad,
    (il."UnitPrice" * il."Quantity") AS subtotal
FROM public."InvoiceLine" il
INNER JOIN public."Invoice" i ON il."InvoiceId" = i."InvoiceId"
INNER JOIN public."Customer" c ON i."CustomerId" = c."CustomerId"
INNER JOIN public."Track" t ON il."TrackId" = t."TrackId"
ORDER BY i."InvoiceId" ASC, il."InvoiceLineId" ASC;

-- Ejercicio 11: Ventas por país
SELECT 
    i."BillingCountry" AS pais_facturacion,
    COUNT(i."InvoiceId") AS cantidad_facturas,
    SUM(i."Total") AS total_vendido
FROM public."Invoice" i
GROUP BY i."BillingCountry"
ORDER BY total_vendido DESC;

-- Ejercicio 12: Cinco artistas con mayores ventas
SELECT 
    ar."Name" AS artista,
    SUM(il."Quantity") AS unidades_vendidas,
    SUM(il."UnitPrice" * il."Quantity") AS ingresos_generados
FROM public."InvoiceLine" il
INNER JOIN public."Track" t ON il."TrackId" = t."TrackId"
INNER JOIN public."Album" al ON t."AlbumId" = al."AlbumId"
INNER JOIN public."Artist" ar ON al."ArtistId" = ar."ArtistId"
GROUP BY ar."ArtistId", ar."Name"
ORDER BY ingresos_generados DESC
LIMIT 5;

-- -----------------------------------------------------------------------------
-- ETAPA 4: ANÁLISIS Y OPTIMIZACIÓN (EJERCICIOS 13 AL 16)
-- -----------------------------------------------------------------------------

-- Ejercicio 13: Plan inicial antes del índice
EXPLAIN ANALYZE
SELECT 
    "TrackId",
    "Name",
    "Composer"
FROM public."Track"
WHERE "Composer" = 'Steve Harris';

-- Ejercicio 14: Creación de índice simple y re-evaluación
CREATE INDEX IF NOT EXISTS idx_track_composer
ON public."Track" ("Composer");

ANALYZE public."Track";

EXPLAIN ANALYZE
SELECT 
    "TrackId",
    "Name",
    "Composer"
FROM public."Track"
WHERE "Composer" = 'Steve Harris';

-- Ejercicio 15: Plan inicial e índice compuesto
EXPLAIN ANALYZE
SELECT 
    "TrackId",
    "Name",
    "UnitPrice"
FROM public."Track"
WHERE "GenreId" = 1
  AND "UnitPrice" = 0.99;

CREATE INDEX IF NOT EXISTS idx_track_genre_price
ON public."Track" ("GenreId", "UnitPrice");

ANALYZE public."Track";

EXPLAIN ANALYZE
SELECT 
    "TrackId",
    "Name",
    "UnitPrice"
FROM public."Track"
WHERE "GenreId" = 1
  AND "UnitPrice" = 0.99;

-- Ejercicio 16: Comparación de proyección
-- Versión A (SELECT *)
EXPLAIN ANALYZE
SELECT *
FROM public."Track"
WHERE "Milliseconds" > 300000;

-- Versión B (Solo columnas necesarias)
EXPLAIN ANALYZE
SELECT "TrackId", "Name", "Milliseconds"
FROM public."Track"
WHERE "Milliseconds" > 300000;

-- -----------------------------------------------------------------------------
-- ETAPA 5: RETO FINAL (INFORME DE GÉNEROS MUSICALES)
-- -----------------------------------------------------------------------------

EXPLAIN ANALYZE
SELECT 
    g."Name" AS genero,
    COUNT(DISTINCT t."TrackId") AS canciones_diferentes_vendidas,
    SUM(il."Quantity") AS total_unidades_vendidas,
    SUM(il."UnitPrice" * il."Quantity") AS ingresos_generados,
    ROUND(AVG(il."UnitPrice")::numeric, 2) AS precio_promedio_venta
FROM public."Genre" g
INNER JOIN public."Track" t ON g."GenreId" = t."GenreId"
INNER JOIN public."InvoiceLine" il ON t."TrackId" = il."TrackId"
GROUP BY g."GenreId", g."Name"
HAVING SUM(il."Quantity") > 50
ORDER BY ingresos_generados DESC
LIMIT 5;

-- -----------------------------------------------------------------------------
-- ANEXO: CONSULTA DE LIMPIEZA (ejecutar al finalizar la práctica)
-- -----------------------------------------------------------------------------

-- DROP INDEX IF EXISTS public.idx_track_composer;
-- DROP INDEX IF EXISTS public.idx_track_genre_price;