-- IMPORTANTE:
-- todas las consultas de validacion
-- para los distintos usuarios se llevaron a
-- cabo en archivos aparte por lo que no se
-- incluyen dentro de este archivo

/*
sql_consulta
1. Crear el usuario sql_consulta. El mismo debe tener como base de datos por defecto AdventureWorks.
2. No hará falta que cambie la password al ingresar, sino que la password será predeterminada.
3. Asignarle que sólo pueda leer la información de todas las tablas contenidas dentro de la base de datos AdventureWorks.
4. Loguearse con dicho usuario y ejecutar las siguientes consultas para verificar los permisos:

- Select top 10 * from Person.Contact
- Delete from Person.Contact where contactID=1
*/

USE AdventureWorks2014

CREATE LOGIN sql_consulta

WITH PASSWORD = 'sql_consulta',
CHECK_POLICY = OFF,
DEFAULT_DATABASE = [AdventureWorks2014]
GO

CREATE USER sql_consulta FOR LOGIN sql_consulta

ALTER ROLE db_datareader ADD MEMBER sql_consulta
GO


/*
sql_personas
1. Crear el usuario sql_personas.
2. Este usuario sólo podrá consultar las tablas de esquema Person y no podrá consultar ninguna otra tabla.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para verificar los permisos:

- Select top 10 * from Person.Contact
- Select * from Production.Culture
*/

CREATE LOGIN sql_personas

WITH PASSWORD = 'sql_personas',
CHECK_POLICY = OFF
GO

USE AdventureWorks2014

CREATE USER sql_personas FOR LOGIN sql_personas

GRANT SELECT ON SCHEMA::[Person] TO sql_personas
GO


/*
sql_dba
1. Crear el usuario sql_dba. Utilizará las políticas de claves de Windows Policies.
2. El usuario será dba de todas las bases de datos contenidas dentro de la instancia de SQLServer.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para verificar los permisos:

- Select top 10 * from Person.Contact
- alter database adventureworks set offline
- alter database adventureworks set online

Nota: Refrescar la base de datos para verificar las opciones de offline y online.
*/

CREATE LOGIN sql_dba

WITH PASSWORD = 'SQLSERVER_user_dba_123_!#$',
CHECK_POLICY = ON,
CHECK_EXPIRATION = ON
GO

USE AdventureWorks2014

CREATE USER sql_dba FOR LOGIN sql_dba

ALTER SERVER ROLE sysadmin ADD MEMBER sql_dba
GO


/*
sql_oper
4. Crear el usuario sql_oper. Utilizará las políticas de claves de Windows Policies.
5. El usuario será de operaciones y podrá realizar ejecución de procesos y además recuperar y backupear base de datos.
6. Loguearse con dicho usuario y ejecutar las siguientes consultas para verificar los permisos:

- Select top 10 * from Person.Contact
- BACKUP DATABASE AdventureWorks TO DISK='C:\AdventureWorks.bak'
- BACKUP DATABASE Model TO DISK='C:\Model.bak'
*/

CREATE LOGIN sql_oper

WITH PASSWORD = 'SQLSERVER_user_oper_123_!#$',
CHECK_POLICY = ON,
CHECK_EXPIRATION = ON
GO

USE AdventureWorks2014

CREATE USER sql_oper FOR LOGIN sql_oper

ALTER SERVER ROLE processadmin ADD MEMBER sql_oper -- rol de servidor para ejecutar procesos
ALTER ROLE db_backupoperator ADD MEMBER sql_oper -- rol de base de datos para realizar backups sobre Adventure Works 2014
GO

USE model

CREATE USER sql_oper FOR LOGIN sql_oper
ALTER ROLE db_backupoperator ADD MEMBER sql_oper
GO

/*
sql_app1…3
1. Crear los usuarios sql_app1..3. No expirará su password.
2. Los usuario serán de la aplicación y sólo deberá poder ejecutar los stored procedures de la base de datos Adventureworks
3. Dado que tenemos varios usuarios con los mismos permisos, crear un nuevo role llamado rol_exec y asignar este role a cada usuario.
4. Loguearse con dichos usuarios y ejecutar las siguientes consultas para verificar los permisos:

- Select top 10 * from Person.Contact
- exec uspGetBillOfMaterials 765,'20000901'
*/

CREATE ROLE [rol_exec] -- primero se crea el rol
GO

GRANT EXECUTE TO [rol_exec] -- luego se le asigna el permiso de ejecución para poder usar los SPs
GO

CREATE LOGIN sql_app1

WITH PASSWORD = 'sql_app1',
CHECK_POLICY = ON
GO

CREATE LOGIN sql_app2

WITH PASSWORD = 'sql_app2',
CHECK_POLICY = ON
GO

CREATE LOGIN sql_app3

WITH PASSWORD = 'sql_app3',
CHECK_POLICY = ON
GO

USE AdventureWorks2014

-- creacion de usuarios y asignacion de rol

CREATE USER sql_app1 FOR LOGIN sql_app1
ALTER ROLE [rol_exec] ADD MEMBER sql_app1
GO

CREATE USER sql_app2 FOR LOGIN sql_app2
ALTER ROLE [rol_exec] ADD MEMBER sql_app2
GO

CREATE USER sql_app3 FOR LOGIN sql_app3
ALTER ROLE [rol_exec] ADD MEMBER sql_app3
GO


/*
sql_imple
1. Crear el usuario sql_imple.
2. El usuario sólo se encargará de implementar los scripts en la base de datos.
Es decir, realizará la creación de todos los objetos o modificación de los existentes, pero no podrá ver los datos.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para verificar los permisos:

- Select top 10 * from Person.Contact
- create table test (campo1 int)
- drop table test
- create procedure sp_test as select 1
- drop procedure sp_test
*/

CREATE LOGIN sql_imple

WITH PASSWORD = 'sql_imple',
CHECK_POLICY = OFF
GO

USE AdventureWorks2014

CREATE USER sql_imple FOR LOGIN sql_imple

ALTER ROLE db_ddladmin ADD MEMBER sql_imple -- se asigna el rol de servidor para poder implementar scripts (sentencias DDL)
DENY SELECT ON DATABASE::[AdventureWorks2014] TO sql_imple -- y luego se revoca el permiso de SELECT para que no pueda ver los datos