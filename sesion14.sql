/*
Crea un supertipo Vehiculo con atributos Marca y Año, y un método obtener_antiguedad. Luego, crea un subtipo Automovil que herede de Vehiculo, con un atributo adicional NumeroPuertas y un método descripcion que devuelva una cadena con los detalles del automóvil
*/

DROP TABLE Vehiculos PURGE;
DROP TYPE Camion;
DROP TYPE Automovil;
DROP TYPE Vehiculo;

CREATE OR REPLACE TYPE Vehiculo AS OBJECT (
	Marca VARCHAR2(50),
	Año DATE,
	MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
) NOT FINAL;
/

-- Definir el cuerpo del método
CREATE OR REPLACE TYPE BODY Vehiculo AS
	MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
	BEGIN
		RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, Año) / 12);
	END;
END;
/

CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
	NumeroPuertas NUMBER,
	MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/


CREATE OR REPLACE TYPE BODY Automovil AS
	MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
	BEGIN
		RETURN 'Marca: ' || Marca || ', Año: ' || TO_CHAR(Año, 'YYYY') || ', Numero de puertas: ' || NumeroPuertas;
	END;
END;
/


/*
Crea un subtipo Camion que herede de Vehiculo, con un atributo adicional CapacidadCarga (en toneladas) y sobrescriba el método obtener_antiguedad para sumar 2 años adicionales (los camiones envejecen más rápido). Inserta un camión en la tabla Vehiculos y consulta su antigüedad y descripción
*/


CREATE OR REPLACE TYPE Camion UNDER Vehiculo (
	CapacidadCarga NUMBER,
	OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER,
	MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/


CREATE OR REPLACE TYPE BODY Camion AS
	OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
	BEGIN
		RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, Año) / 12) + 2;
	END;
	
	MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
	BEGIN
        	RETURN 'Marca: ' || Marca || ', Año: ' || TO_CHAR(Año, 'YYYY') || ', Capacidad de carga: ' || CapacidadCarga || ' toneladas';
	END;

END;
/

CREATE TABLE Vehiculos OF Vehiculo;

INSERT INTO Vehiculos
VALUES (Camion('Optimus Prime', TO_DATE('1990-01-10', 'YYYY-MM-DD'), 800));

SELECT
    	TREAT(VALUE(c) AS Camion).Marca AS Marca,
    	TREAT(VALUE(c) AS Camion).Año AS Año,
    	TREAT(VALUE(c) AS Camion).CapacidadCarga AS CapacidadCarga,
    	TREAT(VALUE(c) AS Camion).obtener_antiguedad() AS Antiguedad,
    	TREAT(VALUE(c) AS Camion).descripcion() AS Datos
FROM Vehiculos c
WHERE VALUE(c) IS OF (ONLY Camion);























