SELECT Ciudad, COUNT(*) AS TotalClientes
FROM Clientes
GROUP BY Ciudad
HAVING COUNT(*) = 1;

SELECT c.Nombre, SUM(p.Total) AS TotalGastado,
AVG(p.Total) AS PromedioPorPedido
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre;

COMMIT;