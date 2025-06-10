/*
Item 1.-

1. Explica la diferencia entre un procedimiento almacenado y una función almacenada en PL/SQL. Da un ejemplo de cuándo usarías cada uno en el contexto de la base de datos de la prueba.
2. Describe cómo usarías un parámetro IN OUT en un procedimiento almacenado. Escribe un ejemplo de un procedimiento que use un parámetro IN OUT para actualizar y devolver la cantidad en inventario después de un movimiento.
3. ¿Cómo se puede usar una función almacenada dentro de una consulta SQL? Escribe un ejemplo de una función que calcule el valor total del inventario de un producto (Precio * Cantidad) y úsala en una consulta para listar los productos con su valor total.
4. Explica qué es un trigger y menciona dos tipos de eventos que pueden dispararlo. Da un ejemplo de un trigger que se dispare después de insertar un movimiento en la tabla Movimientos y actualice la cantidad en Inventario.


1.- el procedimiento me permite devolver un valor para uso en el codigo, la funcion me permite trabajar directamente alterando la tablas
El procedimiento lo usare en el ejercicio 1 del item 2, ya que es nesesario para poder interactuar con los valores de las tablas en general, sin nesesariamente devolverme un valor, mientras que la funcion la ocuparia en el ejercicio 2 del item 2, ya que nesesito calcular un valor en especifico, el cual luego devo de volver a usar en un procedimiento.

2.- simplemente tomaria el id del producto para saber cual actualizar, y su nueva cantidad, luego sumaria la nueva cantidad con la antigua y la suma seria la nueva cantidad

CREATE OR REPLACE PROCEDURE procedimiento_almacenado(p_producto_id IN NUMBER, i_cantidad, OUT NUMBER) AS
BEGIN
  	UPDATE Inventario
  	SET Cantidad = Cantidad + i_cantidad
  	WHERE ProductoID = p_producto_id;
	
	SELECT Cantidad INTO p_cantidad FROM Inventario WHERE ProductoID = p_producto_id;
END;
/

3.-

CREATE OR REPLACE FUNCTION valor_inventario_producto(p_producto_id IN NUMBER) RETURN NUMBER AS
 	v_valor NUMBER;
BEGIN
	SELECT Precio * Cantidad INTO v_valor
	FROM Productos P
	JOIN Inventario I ON P.ProductoID = I.ProductoID
	WHERE P.ProductoID = p_producto_id;
	RETURN NVL(v_valor, 0);
END;
/


4.- Es un codigo similar a una funcion, solo que a este se le denominan unas condicionales que se relacionan con el codigo, condicionales que usa para actuar de manera automatica al momento de que una de las mismas se cumple, eventos como el insertar valores en una tabla, borrar valores en la misma, cambiar valores, etc.

CREATE OR REPLACE TRIGGER ejemplo_movimientos
AFTER INSERT ON Movimientos
FOR EACH ROW
BEGIN
        INSERT INTO Inventario(Cantidad)
        VALUES (:NEW.Cantidad);
END;
/

*/






/*
Item 2.-

1. Escribe un procedimiento registrar_movimiento que reciba un ProductoID, TipoMovimiento ('Entrada' o 'Salida'), y Cantidad (parámetros IN). El procedimiento debe:
	○ Insertar un nuevo movimiento en la tabla Movimientos (usa el próximo MovimientoID disponible).
	○ Actualizar la cantidad en Inventario según el tipo de movimiento.
	○ Actualizar la FechaActualizacion en Inventario a la fecha actual.
	○ Manejar excepciones si el producto no existe o si la cantidad en inventario se vuelve negativa.

2. Escribe una función calcular_valor_inventario_proveedor que reciba un ProveedorID (parámetro IN) y devuelva el valor total del inventario de los productos de ese proveedor (suma de Precio * Cantidad). Luego, usa la función en un procedimiento mostrar_valor_proveedor que muestre el valor total del inventario por proveedor para todos los proveedores.

3. Crea un trigger auditar_movimientos que se dispare después de insertar o eliminar un movimiento en la tabla Movimientos y registre el MovimientoID, ProductoID, TipoMovimiento, Cantidad, la acción ('INSERT' o 'DELETE') y la fecha en una tabla de auditoría AuditoriaMovimientos.

*/


-- Ejercicio uno
CREATE OR REPLACE PROCEDURE registrar_movimiento(m_producto_id IN NUMBER, m_tipo_movimiento IN VARCHAR2, m_cantidad IN NUMBER) AS
	v_aux NUMBER,
	v_bux NUMBER,
BEGIN
	SELECT Cantidad INTO v_bux FROM Inventario WHERE ProductoID = m_producto_id;
	IF m_tipo_movimiento = 'Entrada' THEN
		v_bux := v_bux +  m_cantidad;
	ELSIF m_tipo_movimiento = 'Salida' THEN 
		v_bux := v_bux -  m_cantidad;
	END IF;

	INSERT INTO Movimientos(MovimientoID, ProductoID, TipoMovimiento, Cantidad)
	VALUES (v_aux, m_producto_id, m_tipo_movimiento, m_cantidad);

	UPDATE Inventario
	SET Cantidad = v_bux,
        	FechaActualizacion = SYSDATE
	WHERE ProductoID = m_producto_id;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    	DBMS_OUTPUT.PUT_LINE('Error:' || SQLERRM);
    WHEN OTHERS THEN
        ROLLBACK;
END;
/


EXEC registrar_movimiento(2, 'Entrada', 10);









-- Ejercicio dos
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION calcular_valor_inventario_proveedor(p_proveedor_id IN NUMBER) RETURN 
NUMBER AS
	v_total NUMBER;
BEGIN
	SELECT SUM(Productos.Precio * Inventario.Cantidad) INTO v_total
	FROM Productos
	INNER JOIN Inventario
	ON Productos.ProductoID = Inventario.ProductoID
	WHERE Productos.ProveedorID = p_proveedor_id;
	RETURN NVL(v_total, 0);
END;
/

CREATE OR REPLACE PROCEDURE mostrar_valor_proveedor AS
	v_proveedor_id NUMBER;
	v_valor_inventario NUMBER;
	CURSOR c_proveedores IS
		SELECT ProveedorID, Nombre, Ciudad FROM Proveedores;
BEGIN
	FOR proveedor IN c_proveedores LOOP
        	v_proveedor_id := proveedor.ProveedorID;
        	v_valor_inventario := calcular_valor_inventario_proveedor(v_proveedor_id);
        DBMS_OUTPUT.PUT_LINE('Proveedor id: ' || proveedor.ProveedorID || ' Nombre: ' || proveedor.Nombre || ' Ciudad: ' || proveedor.Ciudad || ' Valor Inventario: ' || v_valor_inventario);
    	END LOOP;
END;
/

EXEC mostrar_valor_proveedor;








-- Ejercicio Tres
DROP TABLE AuditoriaMovimientos;

CREATE TABLE AuditoriaMovimientos(
	AuditoriaID NUMBER PRIMARY KEY,
	MovimientoID NUMBER,
	ProductoID NUMBER,
	TipoMovimiento NUMBER,
	Cantidad NUMBER,
	Accion VARCHAR2(10),
	FechaRegistro DATE
);

CREATE OR REPLACE TRIGGER auditar_movimientos
AFTER INSERT OR DELETE ON Movimientos
FOR EACH ROW
BEGIN
    	IF INSERTING THEN
        	INSERT INTO AuditoriaMovimientos(MovimientoID, ProductoID, TipoMovimiento, Cantidad, Accion, FechaRegistro)
        	VALUES (:NEW.MovimientoID, :NEW.ProductoID, :NEW.TipoMovimiento, :NEW.Cantidad, 'INSERT', SYSDATE);
	ELSIF DELETING THEN 
		INSERT INTO AuditoriaMovimientos(MovimientoID, ProductoID, TipoMovimiento, Cantidad, Accion, FechaRegistro)
		VALUES (:OLD.MovimientoID, :OLD.ProductoID, :OLD.TipoMovimiento, :OLD.Cantidad, 'DELETE', SYSDATE);
	END IF;
END;

/


INSERT INTO Movimientos(ProductoID, TipoMovimiento, Cantidad)
VALUES (100, 1, 50);

DELETE FROM Movimientos WHERE MovimientoID = 5;
SELECT * FROM AuditoriaMovimientos;



