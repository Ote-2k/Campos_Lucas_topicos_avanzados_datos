/*************************************************
1. Escribe un bloque anónimo que use un cursor
explícito basado en un objeto para listar 2
atributos de alguna clase, ordenados por uno de
los atributos.
2. Escribe un bloque anónimo que use un cursor
explícito con parámetro basado en un objeto para
aumentar un 10% el total de la suma de algún
atributo numérico de un elemento de una tabla y
muestre los valores originales y actualizados.
Usa FOR UPDATE o usa función dentro del objeto
*************************************************/

-- Tipo de objeto para clientes
CREATE OR REPLACE TYPE tipo_cliente AS OBJECT (
	ClienteID NUMBER,
	Nombre VARCHAR2(50)
);
/

DECLARE
	-- Objeto Cursor
	CURSOR cliente_cursor IS
		SELECT tipo_cliente(ClienteID, Nombre)
		FROM Clientes
		ORDER BY Nombre DESC;

	v_cliente tipo_cliente;
BEGIN
	OPEN cliente_cursor;
	LOOP
		FETCH cliente_cursor INTO v_cliente;
		EXIT WHEN cliente_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('ClienteID: ' || v_cliente.ClienteID || ', Nombre: ' || v_cliente.Nombre);
	END LOOP;
	CLOSE cliente_cursor;
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;
END;
/




-- Tipo de objeto para pedidos
CREATE OR REPLACE TYPE tipo_pedido AS OBJECT (
	PedidoID NUMBER,
	Total NUMBER
);
/

DECLARE
	CURSOR pedido_cursor(p_min_total NUMBER) IS
		SELECT tipo_pedido(PedidoID, Total)
		FROM Pedidos
		WHERE Total < p_min_total
		FOR UPDATE;

	v_pedido tipo_pedido;
	v_total_actualizado NUMBER;
BEGIN
	OPEN pedido_cursor(400);
	LOOP
		FETCH pedido_cursor INTO v_pedido;
		EXIT WHEN pedido_cursor%NOTFOUND;

		v_total_actualizado := v_pedido.Total * 1.1;

		UPDATE Pedidos
		SET Total = v_total_actualizado
		WHERE PedidoID = v_pedido.PedidoID;

		DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido.PedidoID);
		DBMS_OUTPUT.PUT_LINE('  Total original: ' || v_pedido.Total);
		DBMS_OUTPUT.PUT_LINE('  Total actualizado: ' || v_total_actualizado);
	END LOOP;
	CLOSE pedido_cursor;
	COMMIT;
END;
/

