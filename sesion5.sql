/*
1. Escribe un bloque anónimo que use un cursor
explícito para listar 2 atributos de alguna
clase, ordenados por uno de los atributos.

2. Escribe un bloque anónimo que use un cursor
explícito con parámetro para aumentar un 10% el
total de la suma de algún atributo numérico de un
elemento de una tabla y muestre los valores
originales y actualizados. Usa FOR UPDATE.
*/

DECLARE
	CURSOR cliente_cursor IS
		SELECT ClienteID, Nombre
		FROM Clientes
		ORDER BY Nombre Desc;
	v_id NUMBER;
	v_nombre VARCHAR2(50);
BEGIN
	OPEN cliente_cursor;
	LOOP
		FETCH cliente_cursor INTO v_id, v_nombre;
		EXIT WHEN cliente_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Nombre: ' || v_nombre);
	END LOOP;
	CLOSE cliente_cursor;
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;

END;
/



DECLARE
	-- Cursor con pedidos minimos (filtrados)
	CURSOR pedido_cursor(p_min_total NUMBER) IS
		SELECT PedidoID, Total
		FROM Pedidos
		WHERE Total < p_min_total
		FOR UPDATE;

	v_pedido_id NUMBER;
	v_total NUMBER;
	v_total_actualizado NUMBER;
BEGIN
	OPEN pedido_cursor(20);
	LOOP
		FETCH pedido_cursor INTO v_pedido_id, v_total;
		EXIT WHEN pedido_cursor%NOTFOUND;

		v_total_actualizado := v_total * 1.1;

		-- se actualiza el valor
		UPDATE Pedidos
		SET Total = v_total_actualizado
		WHERE CURRENT OF pedido_cursor;

		-- valores antes y despues
		DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido_id || ':');
		DBMS_OUTPUT.PUT_LINE('  Total original: ' || v_total);
		DBMS_OUTPUT.PUT_LINE('  Total actualizado: ' || v_total_actualizado);
	END LOOP;
	CLOSE pedido_cursor;
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;
END;
/
