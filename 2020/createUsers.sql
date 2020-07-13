CREATE USER audit_energia IDENTIFIED BY 'unaclave'
DEFAULT TABLESPACE 'USERS'
TEMPORARY TABLESPACE 'TEMP';

ALTER USER audit_energia QUOTA UNLIMITED ON USERS;

-- Roles
GRANT "CONNECT" TO audit_energia;
GRANT "RESOURCE" TO audit_energia;

-- Privilegios del sistema
GRANT CREATE SESSION TO audit_energia;
GRANT CREATE TABLE TO audit_energia;
GRANT CREATE VIEW TO audit_energia;
GRANT CREATE PROCEDURE TO audit_energia;
GRANT CREATE SYNONYM TO audit_energia;
GRANT CREATE TRIGGER TO audit_energia;


-- =============================
-- 			Aquí Termina
-- =============================

-- Sentencia para bloquear/desbloquear usuarios
SELECT user_id, username, created, expiry_date, account_status,
default_tablespace default_ts, temporary_tablespace temp_ts
FROM dba_users
WHERE username = UPPER('audit_energia');

-- Bloquear/desbloquear usuarios
ALTER USER audit_energia ACCOUNT LOCK;
ALTER USER audit_energia ACCOUNT UNLOCK;

--Cambiar contraseña
ALTER USER audit_energia IDENTIFIED BY "unpassword"

--Vista para conocer los privilegios del sistema
--Asignados a un usuario
SELECT *
FROM dba_sys_privs
WHERE grantee = UPPER("audit_energia");

--Vista para conocer los roles del sistema
--Asignados a un usuario
SELECT *
FROM dba_role_privs
WHERE grantee = UPPER("audit_energia");

-- Para borrar usuario
DROP USER audit_energia CASCADE;
