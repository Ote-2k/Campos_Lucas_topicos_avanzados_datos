/* Crea un índice compuesto en la tabla DetallesPedidos para las columnas PedidoID y ProductoID. Luego, escribe una consulta que use este índice y analiza su plan de ejecución*/

CREATE INDEX idx_detallespedido_comp ON DetallesPedidos(PedidoID, ProductoID);
SELECT * FROM DetallesPedidos
WHERE PedidoID = 101 AND ProductoID = 1;

EXPLAIN PLAN FOR
SELECT * FROM DetallesPedidos
WHERE PedidoID = 101 AND ProductoID = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/* Crea una tabla Ventas particionada por hash usando la columna ClienteID (4 particiones). Inserta datos de Pedidos y escribe una consulta que muestre el total de ventas por cliente, verificando que las particiones se usen*/

CREATE TABLE Ventas (
	id INT NOT NULL,
	ClienteID INT NOT NULL,
	detallePedido VARCHAR(30),
	ciudad	VARCHAR(30),
	Fecha DATE
)

PARTITION BY HASH(ClienteID)
PARTITIONS 4;

--esta parte esta practicamente copiada 1 a 1 del trabajo del fabian debido a que el fue el que me ayudo a terminar esta parte, y no supimos como hacerlo de otra manera
SELECT 
    PARTITION_NAME, 
    COUNT(*) AS Registros
FROM 
    USER_TAB_PARTITIONS p
JOIN 
    TABLE(
        SELECT /*+ dynamic_sampling(4) */ * FROM Ventas
    ) v 
    ON MOD(v.ClienteID, 4) = TO_NUMBER(SUBSTR(p.PARTITION_NAME, -1))
GROUP BY PARTITION_NAME;

SELECT 
    ClienteID,
    DUMP(ROWID) AS RawRowID
FROM Ventas;