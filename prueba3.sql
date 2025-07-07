/*
Alumno: Lucas Campos Cortes.

Item 1 // Teoria
1. Explica qué es una transacción en una base de datos y describe a través de un ejemplo cómo usarías savepoints para manejar errores parciales en un procedimiento que registra horas trabajadas en RegistrosTiempo.

es cuando un conjunto o bloque de codigo se ejecuta en su totalidad, si es que funciona se le conoce como transaccion. usaria save points antes de insertar el registro de las horas trabajadas, para que en caso de un error al momento de insertar datos, se pueda hacer un rollback al savepont, ademas de dar un comentario en el error, diciendo el que paso, y avisando el que se va a volver al savepoint

2. ¿Qué es un Data Warehouse y cómo se diferencia de una base de datos transaccional? Describe cómo diseñarías una tabla de hechos para analizar las horas trabajadas por proyecto en la base de datos de la prueba.

es un sistema "centralizado" que almacena datos estructurados de múltiples fuentes, diseñado específicamente para la generación de informes y análisis. y se diferencia de la misma en que la datawarehouse sirve mas como una central para ver los datos generales del sistema y trabajar con ellos directamente, mientras que la base de datos trnsaccional sirve mas para trabajar con un conjunto de codigo completo

3. Explica cómo se implementa la herencia en Oracle usando tipos de objetos. Da un ejemplo de una jerarquía de tipos para modelar empleados (Empleado → Desarrollador) en la base de datos de la prueba.

la herencia se implemente de manera en la que se crea una clase en base a los componentes de otra, por ejemplo, en la tabla de la prueba tenemos la tabla:
-- Crear tabla para empleados (base para herencia)
CREATE TABLE Empleados (
    EmpleadoID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nombre VARCHAR2(100),
    TipoEmpleado VARCHAR2(50), -- Para simular herencia (Desarrollador, etc.)
    Salario NUMBER(10,2)
);

donde sale el atributo "tipoempleado", gracias a este atributo, podemos crear una tabla llamada desarrollador con el prefijo "UNDER Empleados" lo cual hara que la tabla posea todas las columnas de la tabla empleado ademas de las que le insertemos ahora, pero no solo eso, sino que tambien al momento de crear un "empleado" si especificamos que el mismo es un desarrollador, aunque estemos llamando a la tabla de empleados, se creara un desarrollador por que gracias a la herencia todos los datos del empleado pasan directamente al desarrollador, esto es 10 veces mas facil de explicar aqui que en java.

4. Describe las ventajas y desventajas de usar índices y particiones en una base de datos. ¿Cómo usarías un índice y una partición para mejorar el rendimiento de consultas en la tabla RegistrosTiempo?

los indices son bastante utiles por lo que voy a partir por sus desventajas:
- no son utiles en pequeñas bases de datos, intentar agregar indices solo termina gastando mas recursos en general por una optimizacion que no es nesesaria cuando los datos son minusculos, ademas de que poseen un limite de cuantos datos pueden mostrar antes de volverse muy complicados o directametne no funcionar

ventajas:
- nos permiten ahorrar un monton de tiempo con grandes bases de datos, ya que pueden filtrar grandes cantidades de datos segun las metricas que nosotros le estipulemos al indice, ademas de poder mostrarnos datos especificos de multiples tablas a la vez

Particiones:
ventajas:
-funcionan de mejor manera que los indices, permitiendo separar tablas multiples veces por datos especificos, ademas de ser mas simples de implementar logicamente y hacer consultas

desventajas:
-similar a los indices no son muy utiles cuando la cantidad de datos es pequeñan no solamente eso, las particiones no pueden editar ciertos tipos de tablas(no me acuerdo cuales pero se q cuando las probe me daban errores), por lo que para generar particiones de esas tablas, se debe crear una NUEVA tabla a la cual se le carguen estos datos, haciendo el problema ams engorroso y cargado

en un archivo aparte crearia un indice llamado horas_trabajadas el cual filtraria los datos de la columan HorasTrabajadas para mostrar aquellos turnos lso cuales cumplen con un estandar de decente de horas trabajadas (ej. aquellos empleados que trabajaron mas de 5 horas al dia en promedio),
mientras que la particion la ocuparia para separar las fechas de la tabla, creando un orden en el cual se pueda ver cuantas horas o cuantos turnos se trabajaron durante cierto mes o meses  



Item 2 // Codigo

1. Escribe un procedimiento registrar_tiempo que reciba un AsignacionID, Fecha y HorasTrabajadas (parámetros IN). El procedimiento debe:
	○ Insertar un nuevo registro en RegistrosTiempo (usa el próximo RegistroID disponible).
	○ Validar que las horas no excedan 8 por día para esa asignación.
	○ Usar savepoints para manejar errores (por ejemplo, si las horas exceden el límite).
	○ Manejar excepciones y transacciones adecuadamente.

2. Diseña una tabla de hechos Fact_HorasTrabajadas y una dimensión Dim_Proyecto para un Data Warehouse basado en la base de datos de la prueba. Escribe una consulta analítica que muestre las horas totales trabajadas por proyecto y mes.

3. Crea un índice compuesto en RegistrosTiempo para las columnas AsignacionID y Fecha. Luego, particiona la tabla RegistrosTiempo por rango de fechas (mensual, para 2025).
Escribe una consulta que muestre las horas trabajadas por asignación en marzo de 2025 y analiza su plan de ejecución.

*/

SET SERVEROUTPUT ON

-- Ejercicio 1.-

CREATE OR REPLACE PROCEDURE registrar_tiempo(p_asignacion_id IN NUMBER, p_fecha IN DATE, p_horas IN NUMBER) AS
    v_registro_horas NUMBER;
    v_registro_dias NUMBER;
    v_aux NUMBER;
BEGIN
    SAVEPOINT comienzo_registro_tiempo;
    -- punto 2
    SELECT NVL(SUM(HorasTrabajadas), 0) INTO v_registro_horas FROM RegistrosTiempo
    WHERE AsignacionID = p_asignacion_id AND Fecha = p_fecha;
    IF v_registro_horas + p_horas > 8 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se pueden registrar más de 8 horas por día.');
    END IF;
    -- punto uno
    INSERT INTO RegistrosTiempo (AsignacionID, Fecha, HorasTrabajadas)
    VALUES (p_asignacion_id, p_fecha, p_horas);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    	ROLLBACK TO comienzo_registro_tiempo;
   	 DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM || '. Vuela al comienzo.');
    ROLLBACK; -- por seguridad a.
END;
/

BEGIN
  registrar_tiempo(1, TO_DATE('2025-07-07', 'YYYY-MM-DD'), 2.0);
END;
/


-- Ejercicio 2.-

CREATE TABLE Fact_HorasTrabajadas (
    FactID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProductoID NUMBER,
    FechaID NUMBER,
    CantidadMovimiento NUMBER,
    TipoMovimiento VARCHAR2(10),
    CONSTRAINT fk_fact_inventario_producto FOREIGN KEY
    (ProductoID) REFERENCES Dim_Producto(ProductoID),
    CONSTRAINT fk_fact_inventario_tiempo FOREIGN KEY
    (FechaID) REFERENCES Dim_Tiempo(FechaID)
);

CREATE TABLE Dim_Proyecto (
    ProyectoID NUMBER PRIMARY KEY,
    NombreProyecto VARCHAR2(100),
    Presupuesto NUMBER(14,2),
    FechaInicio DATE,
    FechaFin DATE
);

SELECT


-- Ejercicio 3.-

CREATE INDEX idx_registro_tiempo_comp ON RegistrosTiempo (AsignacionID, Fecha);

ALTER TABLE RegistrosTiempo ADD PARTITION BY RANGE (Fecha) (
    PARTITION p_jan_2025 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_feb_2025 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION p_mar_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_apr_2025 VALUES LESS THAN (TO_DATE('2025-05-01', 'YYYY-MM-DD')),
    PARTITION p_may_2025 VALUES LESS THAN (TO_DATE('2025-06-01', 'YYYY-MM-DD')),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);

SELECT AsignacionID, SUM(HorasTrabajadas) AS Total_diario, Fecha FROM RegistrosTiempo
WHERE Fecha BETWEEN TO_DATE('2025-03-01', 'YYYY-MM-DD') AND TO_DATE('2025-03-31', 'YYYY-MM-DD')
GROUP BY AsignacionID, Fecha
ORDER BY AsignacionID;

/* quiero destacar que esta parte no la entendi mucho realmente, nose si es que no le puse antencion en clases o no las practique en los ejercicios, pero el EXPLAIN PLAN FOR lo saque completamente de internet ya que no entedia a que se referia cuando me lo pedia, e internet me tiraba esto o una forma de explicar los algoritmos de mi codigo */
EXPLAIN PLAN FOR
	SELECT AsignacionID, SUM(HorasTrabajadas) AS Total_diario, Fecha FROM RegistrosTiempo
	WHERE Fecha BETWEEN TO_DATE('2025-03-01', 'YYYY-MM-DD') AND TO_DATE('2025-03-31', 'YYYY-MM-DD')
	GROUP BY AsignacionID, Fecha
	ORDER BY AsignacionID;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


