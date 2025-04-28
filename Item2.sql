/*
-- 1. Escribe un bloque PL/SQL con un cursor explícito que liste los departamentos con un salario promedio mayor a 600000, mostrando el nombre del departamento y el promedio de salario de sus empleados. Usa un JOIN entre Departamentos y Empleados.
*/

DECLARE
	CURSOR salario_prom IS
	SELECT t1.Nombre,  AVG(t2.Salario) AS promedio
	FROM Departamentos t1
	JOIN Empleados t2 ON t1.DepartamentoID = t2.DepartamentoID
	GROUP BY t1.Nombre
	HAVING AVG(t2.Salario) > 600000;
	v_nombre VARCHAR2(50);
	v_total NUMBER;
BEGIN
	OPEN salario_prom;
	LOOP
		FETCH salario_prom INTO v_nombre, v_total;
		EXIT WHEN salario_prom%NOTFOUND;
		IF v_total > 600000 THEN
			DBMS_OUTPUT.PUT_LINE('Departamento: ' || v_nombre || ' Salario Promedio:  ' || v_total);
		END IF;
	END LOOP;
	CLOSE salario_prom;
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;
END;
/

/*
2. Escribe un bloque PL/SQL con un cursor explícito que reduzca un 5% el presupuesto de los proyectos que tienen un presupuesto mayor a 1500000. Usa FOR UPDATE y maneja excepciones.
*/

DECLARE
	CURSOR reduccion_cursor IS
	SELECT ProyectoID, Presupuesto
	FROM Proyectos
	WHERE Presupuesto > 1500000
	FOR UPDATE;
	v_proyectoid NUMBER;
	v_presupuesto NUMBER;
	v_reduccion NUMBER := 5;
BEGIN
	OPEN reduccion_cursor;
	LOOP
		FETCH reduccion_cursor INTO v_proyectoid, v_presupuesto;
		EXIT WHEN reduccion_cursor%NOTFOUND;
		UPDATE Proyectos
		SET Presupuesto = v_presupuesto - (v_presupuesto * (v_reduccion/100))
		WHERE ProyectoID = v_proyectoid;
		DBMS_OUTPUT.PUT_LINE('Producto ' || v_proyectoid || ' actualizado a: ' || (v_presupuesto - (v_presupuesto * (v_reduccion / 100))));
	
	END LOOP;
	CLOSE reduccion_cursor;
	DBMS_OUTPUT.PUT_LINE('a');
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
	 DBMS_OUTPUT.PUT_LINE('Algo paso: ' || SQLERRM);
	 IF reduccion_cursor%ISOPEN THEN
	 	CLOSE reduccion_cursor;
	 END IF;
END;
/


/*
3. Crea un tipo de objeto empleado_obj con atributos empleado_id, nombre, y un método get_info. Luego, crea una tabla basada en ese tipo y transfiere los datos de Empleados a esa tabla. Finalmente, escribe un cursor explícito que liste la información de los empleados usando el método get_info.
*/

CREATE OR REPLACE empleado_obj(
	empleado_id, nombre, get_info
);

CREATE TABLE Objetos (
	empleado empleados_obj(EmpleadoID, Nombre)
);


DECLARE
    CURSOR info_cursor IS
        SELECT Empleados FROM Objetos;
    v_empleado empleado_obj;
BEGIN
    OPEN info_cursor;
    LOOP
        FETCH info_cursor INTO v_empleado;
        EXIT WHEN info_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_empleado.get_info);
    END LOOP;
    CLOSE info_cursor;
    DBMS_OUTPUT.PUT_LINE('a');
    COMMIT;
END;
/





