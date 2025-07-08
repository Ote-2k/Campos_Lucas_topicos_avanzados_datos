/* Crea un usuario user_analista y un rol rol_analista. El rol debe tener permisos para consultar (SELECT) todas las tablas de curso_topicos y para insertar (INSERT) en la tabla Pedidos. Asigna el rol al usuario y prueba los permisos */

CREATE USER user_analista IDENTIFIED BY uno23;

GRANT CREATE SESSION TO user_analista;

CREATE ROLE rol_analista;
-- esto me lo tuvo que explicar el fabian
BEGIN
   FOR t IN (
      SELECT table_name FROM all_tables 
      WHERE owner = 'CURSO_TOPICOS'
   ) LOOP
      EXECUTE IMMEDIATE 'GRANT SELECT ON curso_topicos.' || t.table_name || ' TO rol_analista';
   END LOOP;
END;
/

GRANT INSERT ON curso_topicos.Pedidos TO rol_analista;

GRANT rol_analista TO user_analista;

-- pruebas que deberian de funcionar
SELECT * FROM curso_topicos.Productos;

INSERT INTO curso_topicos.Pedidos (PedidoID, ClienteID, FechaPedido)
VALUES (1020, 3, SYSDATE);

-- UPDATE debería fallar (no tiene permiso)
UPDATE curso_topicos.Pedidos SET FechaPedido = SYSDATE WHERE PedidoID = 1020;

/* Configura auditoría para monitorear las acciones de user_analista al consultar la tabla Clientes y al insertar en la tabla Pedidos. Realiza algunas acciones y verifica los registros de auditoría */

SHOW PARAMETER audit_trail;

ALTER SYSTEM SET audit_trail = DB SCOPE=SPFILE;

SHUTDOWN IMMEDIATE;
STARTUP;

AUDIT SELECT ON curso_topicos.Clientes BY user_analista BY ACCESS;

AUDIT INSERT ON curso_topicos.Pedidos BY user_analista BY ACCESS;

-- Ejecutar SELECT (auditado)
SELECT * FROM curso_topicos.Clientes WHERE ROWNUM = 1;

-- Ejecutar INSERT (auditado)
INSERT INTO curso_topicos.Pedidos (PedidoID, ClienteID, FechaPedido)
VALUES (9999, 1, SYSDATE);

-- esto no entendi como funciona
SELECT
   username,
   obj_name,
   action_name,
   timestamp
FROM
   dba_audit_trail
WHERE
   username = 'USER_ANALISTA'
ORDER BY timestamp DESC;
