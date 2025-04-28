/*
1. Escribe un bloque PL/SQL que verifique el valor
numérico de una tabla. Si el valor es menor a
algún bias, lanza una excepción personalizada.
a. Maneja también NO_DATA_FOUND

2. Escribe un bloque PL/SQL que intente insertar una
tupla con ID duplicado
a. Verifique la excepció
*/

DECLARE
	v_precio NUMBER;
	precio_invalido EXCEPTION;
	PRAGMA EXCEPTION_INIT(precio_invalido, -6502); -- Error de tipo de dato invalido
BEGIN
	-- intentamos hacer lo que siempre hago, insertar un dato incorrecto, esta vez a proposito
	INSERT INTO Productos (ProductoID, Nombre, Precio)
	VALUES (100, 'Producto Invalido', TO_NUMBER('abc')); -- forzamos error de tipo

	-- suponiendo que si se inserta algo correcto, lo verificamos
	SELECT Precio INTO v_precio
	FROM Productos
	WHERE ProductoID = 1;

	IF v_precio < 0 THEN
		RAISE precio_invalido;
	END IF;

	DBMS_OUTPUT.PUT_LINE('Precio del producto: ' || v_precio);
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;

EXCEPTION
	WHEN precio_invalido THEN
		DBMS_OUTPUT.PUT_LINE('Error: Precio no válido o negativo');
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado');
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('nose que paso ' || SQLERRM);
END;
/



DECLARE
	id_duplicado EXCEPTION;
	PRAGMA EXCEPTION_INIT(id_duplicado, -00001); -- Codigo de error por valor duplicado
BEGIN
	-- aqui insertamos si o si una id ya existente (la del primer item)
	INSERT INTO Productos (ProductoID, Nombre, Precio)
	VALUES (1, 'Producto Duplicado', 50);

	DBMS_OUTPUT.PUT_LINE('Producto agregado correctamente');
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;

EXCEPTION
	WHEN id_duplicado THEN
		DBMS_OUTPUT.PUT_LINE('Error: Ya existe un producto con ese ID (duplicado)');
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('sigo sin saber que paso' || SQLERRM);
END;
/

