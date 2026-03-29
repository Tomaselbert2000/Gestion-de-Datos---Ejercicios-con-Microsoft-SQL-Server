/*
Dada la base de datos AdventureWorks, realizar los siguientes enunciados: 

Usuarios que se crearán en los ejercicios:

- sql_seg Será el usuario encargado de trabajar con los usuarios
- sql_consulta Sólo podrá consultar los datos
- sql_personas Sólo podrá trabajar con el esquema Person
- sql_dba Será el administrador de la base de datos
- sql_oper Sólo se encargará de realizar los backups y restores de la base de datos
- sql_app1 Sólo podrá ejecutar los stored procedures.
- sql_app2 Sólo podrá ejecutar los stored procedures.
- sql_app3 Sólo podrá ejecutar los stored procedures.
- sql_imple Usuario implementador en producción

Todos los usuarios se crearán con Seguridad de SQLServer
Las claves de los usuarios serán las mismas que su nombre
*/


/*
sql_seg
1. Crear el usuario sql_seg.
2. El usuario será de Seguridad Informática y podrá sólo realizar asignaciones de logins y usuarios de todas las bases de datos.
3. Loguearse con dicho usuario y ejecutar las siguientes consultas para verificar los permisos:

- Select top 10 * from Person.Contact
- Create login sql_1 with password='123'
- Drop login sql_1

Las siguientes sentencias ejecutarlas con el usuario de Seguridad que se acaba de 
crear:
*/

CREATE LOGIN sql_seg WITH PASSWORD = 'sql_seg',
CHECK_POLICY = OFF
GO

CREATE USER sql_seg FOR LOGIN [sql_seg]
GO

USE AdventureWorks2014

ALTER SERVER ROLE securityadmin ADD MEMBER [sql_seg]
ALTER ROLE db_securityadmin ADD MEMBER [sql_seg]
ALTER ROLE db_accessadmin ADD MEMBER [sql_seg]
GO