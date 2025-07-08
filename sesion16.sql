/* Analiza el plan de ejecución de la siguiente consulta y optimízala para que use índices y particiones*/
/*
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c, Pedidos p
WHERE c.ClienteID = p.ClienteID
AND c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01',
'YYYY-MM-DD')
GROUP BY c.Nombre;
*/

SELECT t1.Nombre, COUNT(t2.PedidoID) AS TotalPedidos
FROM Clientes t1
JOIN Pedidos t2 ON t1.ClienteID = t2.ClienteID
WHERE t1.Ciudad = 'Santiago'
  AND t2.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY t1.Nombre;

-- Índice compuesto en Clientes
CREATE INDEX idx_comp ON Clientes(Ciudad, ClienteID);

-- Índice compuesto en Pedidos
CREATE INDEX idx_pedidos_comp ON Pedidos(ClienteID, FechaPedido);


/* Optimiza la siguiente consulta para evitar un FULL TABLE SCAN en DetallesPedidos y analiza el plan de ejecución antes y después de la optimización */
/*
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS
TotalVentas
FROM Productos p, DetallesPedidos dp
WHERE p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
*/

SELECT t3.Nombre, SUM(t4.Cantidad * t3.Precio) AS TotalVentas
FROM Productos t3
JOIN DetallesPedidos t4 ON t3.ProductoID = t4.ProductoID
GROUP BY t3.Nombre;

CREATE INDEX idx_detape_comp ON DetallesPedidos(ProductoID);

EXPLAIN PLAN FOR
SELECT t3.Nombre, SUM(t4.Cantidad * t3.Precio) AS TotalVentas
FROM Productos t3
JOIN DetallesPedidos t4 ON t3.ProductoID = t4.ProductoID
GROUP BY t3.Nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);