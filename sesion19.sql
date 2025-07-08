/* Diseña una estrategia de respaldo para el esquema curso_topicos. Documenta la estrategia en comentarios y escribe un script RMAN para un respaldo completo y un respaldo incremental. */

CONNECT sys AS sysdba;
SELECT log_mode FROM v$database;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

rman target /

CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

-- no quise tocar el noombre de esta ya que lo encontre msaconveniente
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u01/backup/%U';
BACKUP DATABASE;

RUN {
    BACKUP DATABASE PLUS ARCHIVELOG;
    DELETE OBSOLETE;
}

LIST BACKUP;

RUN {
    BACKUP INCREMENTAL LEVEL 1 DATABASE;
    BACKUP ARCHIVELOG ALL;
}

--prueba

DROP TABLE curso_topicos.Productos;

FLASHBACK TABLE curso_topicos.Productos TO BEFORE DROP;

