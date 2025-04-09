SELECT DetalleID, PedidoID FROM DetallesPedidos WHERE DetalleID <
5 ORDER BY PedidoID DESC;

SELECT COUNT(*) AS TotalClientes, Ciudad FROM
Clientes GROUP BY Ciudad
HAVING COUNT(*) > 2;

COMMIT;