/*
Diseña (sin script) una estrategia de alta disponibilidad para el esquema curso_topicos:
○ Número de nodos y su ubicación geográfica.
○ Tipo de replicación (síncrona o asíncrona).
○ Uso de los nodos secundarios (por ejemplo, para reportes).
○ Mecanismo de failover.

Estrategia de Alta Disponibilidad 

- Distribución de nodos:
  • Nodo primario: Ciudad de Concepción, Chile
  • Nodo de respaldo: Ciudad de La Serena, Chile

- Tipo de replicación:
  • Replicación asincrónica usando Oracle Data Guard
  • lo hace mas rapido al responder

- Función del nodo de respaldo:
  • Habilitado para operaciones de lectura utilizando Active Data Guard
  • no interfiere con el nodo principal

- Plan de conmutación (Failover):
  • Activación automática mediante Fast-Start Failover (FSFO)
  • Tiempo estimado de recuperación (MTTR): 4 a 6 minutos
*/


/*
Escribe una consulta de solo lectura que podría ejecutarse en el nodo standby para generar un reporte de ventas por cliente. Explica cómo aprovecharías Active Data Guard.
*/

SELECT cli.ClienteID, cli.Nombre, SUM(f.Total) AS MontoTotal FROM Dim_Cliente cli
JOIN Fact_Pedidos f ON cli.ClienteID = f.ClienteID
JOIN Dim_Tiempo t ON f.FechaID = t.FechaID
WHERE t.Año = 2025 AND t.Mes BETWEEN 1 AND 6
GROUP BY cli.ClienteID, cli.Nombre
ORDER BY MontoTotal DESC;

/*
lo anterior se ejecuta con active guard. El nodo standby en el que se ejecuta está sincronizado en tiempo real con el nodo principal, pero en modo de solo lectura.
Esto permite que las consultas analíticas no consuman recursos.
*/