/*
Crea una función calcular_edad_cliente que reciba un ClienteID (parámetro IN) y devuelva la edad del cliente en años (basado en FechaNacimiento). Maneja excepciones si el cliente no existe.
*/

CREATE OR REPLACE FUNCTION calcular_edad_cliente(c_cliente_id IN NUMBER) RETURN NUMBER AS
	v_nacimiento DATE;
	v_edad NUMBER;
BEGIN
	SELECT FechaNacimiento INTO v_nacimiento
	FROM Clientes
	WHERE ClienteID = c_cliente_id;
	v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_nacimiento) / 12);
	RETURN v_edad;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20002, 'Cliente con ID ' ||c_cliente_id || ' no encontrado.');
END;
/

-- ejecucion
DECLARE
	v_edad NUMBER;
	v_cliente NUMBER;
BEGIN
	v_cliente := 1;
	v_edad := calcular_edad_cliente(v_cliente);
	DBMS_OUTPUT.PUT_LINE('Edad del cliente ' || v_cliente ||': ' || v_edad);
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

/*
DATEDIFF
15-MAY-90 05-MAY-2025 = 34
20-OCT-85 05-MAY-2025 = 39
10-MAR-95 05-MAY-2025 = 30
*/


/*
Crea una función obtener_precio_promedio que devuelva el precio promedio de todos los productos. Úsala en una consulta SQL para listar los productos cuyo precio está por encima del promedio.
*/



CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
	v_promedios NUMBER;
BEGIN
	SELECT AVG(Precio) INTO v_promedios
	FROM Productos;
	RETURN v_promedios;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20002, 'No hay productos');
END;
/
/*
DECLARE 
	v_aux NUMBER;
	v_bux NUMBER;
	v_cux NUMBER;
	v_pux NUMBER;
BEGIN
	v_pux := obtener_precio_promedio;
	SELECT ProductoID, Nombre, Precio INTO (v_aux, v_bux, v_cux)
	FROM Productos
	WHERE Precio > v_pux;
	DBMS_OUTPUT.PUT_LINE('Promedio de precios: ' || v_pux);
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
*/
SELECT * FROM Productos WHERE Precio > obtener_precio_promedio();
