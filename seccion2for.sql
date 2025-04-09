CREATE VIEW PedidosMouses AS
SELECT DetallesPedidos.ProductoID, DetallesPedidos.PedidoID, DetallesPedidos.Cantidad From DetallesPedidos
WHERE DetallesPedidos.ProductoID = 2;

CREATE VIEW PedidosLaptos AS
SELECT DetallesPedidos.ProductoID, DetallesPedidos.PedidoID, DetallesPedidos.Cantidad From DetallesPedidos
WHERE DetallesPedidos.ProductoID = 1;

COMMIT;