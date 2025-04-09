CLI Oracle > SELECT Nombre
FROM Clientes
WHERE REGEXP_LIKE(Nombre, '^J');
CLI Oracle > SELECT Nombre, Ciudad
FROM Clientes
WHERE REGEXP_LIKE(Ciudad, 'ai');

COMMIT;