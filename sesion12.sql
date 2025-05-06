/*
Crea una función calcular_total_con_descuento que reciba un PedidoID (parámetro IN) y devuelva el total del pedido con un descuento del 10% si el total supera 1000. Usa la función en un procedimiento aplicar_descuento_pedido que actualice el total del pedido.
*/

CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedido_id IN NUMBER) RETURN NUMBER AS
	v_valor NUMBER;
	v_descuento NUMBER;
	v_aux NUMBER;
BEGIN
	SELECT Total INTO v_valor
	FROM Pedidos
	WHERE PedidoID = p_pedido_id;
	IF v_valor > 1000 THEN
		v_descuento := v_valor * 0.1;
	ELSE
		v_descuento := 0;
	END IF;
	v_aux := v_valor - v_descuento;
	RETURN v_aux;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20002, 'Pedido ' || p_producto_id || ' inexistente');
END;
/

DECLARE
	v_descuento NUMBER;
	v_bux NUMBER;
BEGIN
	v_bux := 1;
	v_descuento := calcular_total_con_descuento(v_bux);
	DBMS_OUTPUT.PUT_LINE('Descuento del producto ' || v_bux  || ': ' || v_descuento);
	DBMS_OUTPUT.PUT_LINE('a');

EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

/*
Crea un trigger validar_cantidad_detalle que se dispare antes de insertar o actualizar en DetallesPedidos y verifique que la Cantidad sea mayor a 0. Si no, lanza un error.
*/

CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
  IF :NEW.PedidoID <= 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'El pedido debe de tener una ID');
  END IF;
  IF :NEW.ProductoID <= 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'El producto debe de tener una ID');
  END IF;
  IF :NEW.Cantidad <= 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'no se puede pedir cero de algo, no gaste papel');
END IF;
END;
/

INSERT INTO DetallesPedidos (PedidoID, ProductoID, Cantidad)
VALUES (200, 1, 0);
INSERT INTO DetallesPedidos (PedidoID, ProductoID, Cantidad)
VALUES (0, 2, 2);