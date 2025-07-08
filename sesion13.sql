/*
Crea un procedimiento actualizar_inventario_pedido que reciba un PedidoID (parámetro IN) y reduzca la cantidad de productos en una tabla Inventario (crea la tabla si no existe) según los detalles del pedido. Usa savepoints para manejar errores si no hay suficiente inventario.
*/

CREATE TABLE Inventario(
	ProductoID NUMBER,
	Nombre VARCHAR2(50),
	Cantidad NUMBER,
	CONSTRAINT fk_producto_cliente FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(i_pedido_id IN NUMBER, i_detalle_id IN NUMBER, i_producto_id IN NUMBER, i_cantidad IN NUMBER) AS
    v_stock_actual NUMBER;
BEGIN
    SELECT Cantidad INTO v_stock_actual FROM Inventario
    WHERE ProductoID = i_producto_id FOR UPDATE;
    IF v_stock_actual < i_cantidad THEN
        RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente ' || i_producto_id);
    END IF;

    SAVEPOINT antes_de_insertar;

    INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
    VALUES (i_detalle_id, i_pedido_id, i_producto_id, i_cantidad);

    UPDATE Inventario
    SET Cantidad = Cantidad - i_cantidad
    WHERE ProductoID = i_producto_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Detalle insertado y stock actualizado.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO antes_de_insertar;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Ejecutar
EXEC actualizar_inventario_pedido(107, 3, 5, 2);
EXEC actualizar_inventario_pedido(108, 4, 6, 1);
SELECT * FROM Pedidos WHERE PedidoID = 107;
SELECT * FROM DetallesPedidos WHERE PedidoID = 107;

/*
Diseña una tabla de hechos Fact_Pedidos y una dimensión Dim_Ciudad para un Data Warehouse basado en curso_topicos. Escribe una consulta analítica que muestre el total de ventas por ciudad y año
*/

CREATE TABLE Dim_Ciudad (
    CiudadID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50)
);

INSERT INTO Dim_Ciudad (CiudadID, Nombre)
SELECT ROWNUM, DISTINCT Ciudad FROM Clientes;


CREATE TABLE Dim_Cliente (
    ClienteID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100),
    CiudadID NUMBER,
    CONSTRAINT fk_cliente_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID)
);

INSERT INTO Dim_Cliente (ClienteID, Nombre, CiudadID)
SELECT c.ClienteID, c.Nombre, d.CiudadID
FROM Clientes c
JOIN Dim_Ciudad d ON c.Ciudad = d.Nombre;

CREATE TABLE Dim_Tiempo (
    FechaID NUMBER PRIMARY KEY,
    Fecha DATE,
    Año NUMBER,
    Mes NUMBER,
    Día NUMBER
);

INSERT INTO Dim_Tiempo (FechaID, Fecha, Año, Mes, Día)
SELECT ROWNUM, FechaPedido, EXTRACT(YEAR FROM FechaPedido), EXTRACT(MONTH FROM FechaPedido), EXTRACT(DAY FROM FechaPedido)
FROM (SELECT DISTINCT FechaPedido FROM Pedidos);

CREATE TABLE Fact_Pedidos (
    VentaID NUMBER PRIMARY KEY,
    PedidoID NUMBER,
    ClienteID NUMBER,
    ProductoID NUMBER,
    FechaID NUMBER,
    Cantidad NUMBER,
    Total NUMBER,
    CONSTRAINT fk_venta_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
    CONSTRAINT fk_venta_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);

INSERT INTO Fact_Pedidos (VentaID, PedidoID, ClienteID, ProductoID, FechaID, Cantidad, Total)
SELECT ROWNUM, d.PedidoID, p.ClienteID, d.ProductoID, t.FechaID, d.Cantidad, (pr.Precio * d.Cantidad)
FROM DetallesPedidos d
JOIN Pedidos p ON d.PedidoID = p.PedidoID
JOIN Productos pr ON d.ProductoID = pr.ProductoID
JOIN Dim_Tiempo t ON p.FechaPedido = t.Fecha;

SELECT ciu.Nombre AS Ciudad, t.Año, SUM(f.Total) AS TotalVentas
FROM Fact_Pedidos f
JOIN Dim_Cliente cli ON f.ClienteID = cli.ClienteID
JOIN Dim_Ciudad ciu ON cli.CiudadID = ciu.CiudadID
JOIN Dim_Tiempo t ON f.FechaID = t.FechaID
GROUP BY ciu.Nombre, t.Año
ORDER BY ciu.Nombre, t.Año;
