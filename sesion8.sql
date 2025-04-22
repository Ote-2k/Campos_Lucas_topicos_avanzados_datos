/*
Ejercicio 1: Escribe un cursor explícito que liste los pedidos con total mayor a 500 y muestre el nombre del cliente asociado, usando un JOIN.
*/

DECLARE
	CURSOR pedido_cursor IS
	SELECT t1.PedidoID, t1.Total, t2.Nombre
	FROM Pedidos t1
	JOIN Clientes t2 ON t1.ClienteID = t2.ClienteID
	v_pedido_id NUMBER;
	v_total NUMBER;
	v_nombre VARCHAR2(50);
	COMMIT;
BEGIN
	OPEN pedido_cursor;
	LOOP
		FETCH pedido_cursor INTO v_pedido_id, v_total, v_nombre
		EXIT WHEN pedido_cursor%NOTFOUND;
		IF v_total > 500 THEN
			DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido_id || ': Total ' || v_total || ', Cliente: ' || v_nombre);
		END IF;
	END LOOP;
	CLOSE pedido_cursor;
END;
/

/*
Ejercicio 2: Escribe un cursor explícito que aumente un 15% los precios de productos con precio inferior a 1000 y maneje una excepción si falla.
*/

DECLARE
	CURSOR aumento_cursor IS
	SELECT ProductoID, Precio
	FROM Productos
	WHERE Precio < 1000
	FOR UPDATE;
	v_productoid NUMBER;
	v_precio NUMBER;
	v_aumento NUMBER := 15;
BEGIN
	OPEN aumento_cursor;
	LOOP
		FETCH aumento_cursor INTO v_productoid, v_precio;
		EXIT WHEN aumento_cursor%NOTFOUND;
		UPDATE Productos
		SET Precio = v_precio + (v_precio * (v_aumento/100))
		WHERE CURRENT OF aumento_cursor;
		DBMS_OUTPUT.PUT_LINE('Producto ' || v_productoid || ' actualizado a: ' || (v_precio + (v_precio * (v_aumento / 100))));
	END LOOP;
	CLOSE aumento_cursor;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
	 DBMS_OUTPUT.PUT_LINE('Algo paso: ' || SQLERRM);
	 IF aumento_cursor%ISOPEN THEN
	 	CLOSE aumento_cursor;
	 END IF;
END;
/

/*
Ejercicio 3: Escribe un bloque PL/SQL con un cursor explícito que liste los clientes cuyo total de pedidos (suma de los valores de Total en la tabla Pedidos) sea mayor a 1000, mostrando el nombre del cliente y el total acumulado. Usa un JOIN entre Clientes y Pedidos, y agrupa los resultados con GROUP BY.
*/

DECLARE
	CURSOR pedidost_cursor IS
	SELECT t2.ClienteID, t2.Nombre AS ClienteRegistro, SUM(t1.Total) AS NumeroPedidos
	FROM Clientes t2
	JOIN Pedidos t1 ON t1.ClienteID = t2.ClienteID
	GROUP BY t2.ClienteID, t1.Nombre
	HAVING SUM(t1.Total) > 1000;

	v_IDC Clientes.ClienteID%TYPE;
	v_nombres Clientes.Nombre%TYPE;
	v_total NUMBER;
BEGIN
	OPEN pedidost_cursor;
	LOOP
		FETCH pedidost_cursor INTO v_IDC, v_nombres, v_total;
		EXIT WHEN pedidost_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('ID: ' || v_IDC || ' Nombre: ' || v_nombres || 'Pedidos Totales: ' || v_total);
	END LOOP;
	CLOSE pedidost_cursor;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.LINE('Nose que paso, pero algo paso: ' || SQLERRM);
END;
/








