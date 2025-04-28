/******************************************************
Crea un procedimiento aumentar_precio_producto
que reciba un ProductoID y un porcentaje de
aumento (como parámetros IN), y aumente el precio
del producto en ese porcentaje. Maneja la
excepción si el producto no existe.

2. Crea un procedimiento contar_pedidos_cliente que
reciba un ClienteID (parámetro IN) y devuelva la
cantidad de pedidos de ese cliente (parámetro
OUT). Si el cliente no tiene pedidos, devuelve 0.
*****************************************************/

CREATE OR REPLACE PROCEDURE aumentar_precio_producto(p_producto_id IN NUMBER,p_porcentaje IN NUMBER) AS
    v_precio_actual NUMBER;
BEGIN
    -- sacamos el precio
    SELECT Precio INTO v_precio_actual
    FROM Productos
    WHERE ProductoID = p_producto_id;

    -- Si el producto existe, actualizamos el precio
    UPDATE Productos
    SET Precio = v_precio_actual * (1 + p_porcentaje / 100)
    WHERE ProductoID = p_producto_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Producto con ID ' || p_producto_id || ' no encontrado.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Precio del producto ' || p_producto_id || ' actualizado a: ' || v_precio_actual * (1 + p_porcentaje / 100));
    DBMS_OUTPUT.PUT_LINE('a');
    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Producto con ID ' || p_producto_id || ' no encontrado.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: El precio o el porcentaje deben ser valores válidos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('desconocimiento total = ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(p_cliente_id IN NUMBER,p_total_pedidos OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO p_total_pedidos
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    IF p_total_pedidos IS NULL THEN
        p_total_pedidos := 0;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' tiene ' || p_total_pedidos || ' pedidos.');
    DBMS_OUTPUT.PUT_LINE('a');
    COMMIT;

END;
/

/*
-- no sabia si hacer esto era nesesario o no
DECLARE
    v_total_pedidos NUMBER;
BEGIN
    EXEC contar_pedidos_cliente(2, v_total_pedidos);
    DBMS_OUTPUT.PUT_LINE('Total de pedidos del cliente 2: ' || v_total_pedidos);
END;
/

*/

	