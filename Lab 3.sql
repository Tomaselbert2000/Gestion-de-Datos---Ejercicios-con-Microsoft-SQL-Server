USE AdventureWorks2014;


/*
1. Realizar una consulta que permita devolver la fecha y hora actual
*/

SELECT GETDATE() AS 'Fecha y hora actuales'


/*
2. Realizar una consulta que permita devolver únicamente el año y mes actual: 
Año     Mes 
2010    6 
*/

SELECT

-- a partir de la fecha actual, se extrae el valor aislado para año y mes
DATEPART(YEAR, GETDATE()) AS 'Año',
DATEPART(MONTH, GETDATE()) AS 'Mes'


/*
3. Realizar una consulta que permita saber cuántos días faltan para el día de la primavera (21-Sep)
*/

-- a fin de evitar errores y hacer más flexible la consulta, se evalua si la primavera
-- del año actual ya sucedió, en caso que haya pasado la fecha, se calcula directamente
-- tomando en cuenta el año siguiente

SELECT

CASE -- con la sentencia CASE se abre la estructura condicional
    WHEN DATEFROMPARTS( -- se evalua si la fecha actual es igual o menor a la fecha de la primavera del año actual

        -- en caso de serlo, se calcula la diferencia en dias hasta la fecha dentro del corriente año
        DATEPART(YEAR, GETDATE()), 9, 21) >= GETDATE() THEN DATEDIFF(DAY, GETDATE(), (DATEFROMPARTS(DATEPART(YEAR, GETDATE()), 9, 21)))

    ELSE 
        
        -- en caso que no, a la fecha de la primavera de este año, se le suma un año más con DATEADD
        -- para obtener la cantidad de dias tomando en cuenta el año siguiente
        DATEDIFF(DAY, GETDATE(), DATEADD(YEAR, 1, (DATEFROMPARTS(DATEPART(YEAR, GETDATE()), 9, 21))))

END AS 'Dias restantes hasta la proxima primavera'


/*
4. Realizar una consulta que permita redondear el número 385,86 con únicamente 1 decimal.
*/

SELECT ROUND(385.86, 1) AS '385.86 redondeado con 1 decimal'


/*
5. Realizar una consulta permita saber cuánto es el mes actual al cuadrado. Por ejemplo, si estamos en Junio, sería 62
*/

-- se obtiene el valor numerico del mes actual y se lo eleva al cuadrado con la funcion POWER
SELECT POWER(DATEPART(MONTH, GETDATE()), 2) AS 'Valor de mes actual elevado al cuadrado'


/*
6. Devolver cuál es el usuario que se encuentra conectado a la base de datos
*/

SELECT CURRENT_USER AS 'Usuario conectado a la base de datos'


/*
7. Realizar una consulta que permita conocer la edad de cada empleado (Ayuda: HumanResources.Employee)
*/

-- dado que DATEDIFF cuenta los saltos entre años, se toma en cuenta si el empleado ya cumplió años en el año actual o no

SELECT

HRE.BusinessEntityID AS 'ID Empleado',
CASE

    -- se evalua si la fecha actual de nacimiento del empleado es mayor a la fecha actual (no cumplió años en el año actual)
    -- por lo tanto, como DATEDIFF cuenta el salto de año, se resta en 1 para obtener la edad correcta del empleado
    
    WHEN GETDATE() < DATEFROMPARTS(DATEPART(YEAR, GETDATE()), DATEPART(MONTH, HRE.BirthDate), DATEPART(DAY, HRE.BirthDate)) THEN DATEDIFF(YEAR, HRE.BirthDate, GETDATE()) -1

    -- si el empleado ya cumplió años, el salto de año no afecta a la edad por lo cual es desestimado del resultado
    ELSE DATEDIFF(YEAR, HRE.BirthDate, GETDATE())

END AS 'Edad'

FROM HumanResources.Employee AS HRE


/*
8. Realizar una consulta que retorne la longitud de cada apellido de los Contactos, ordenados por apellido.
En el caso que se repita el apellido devolver únicamente uno de ellos. Por ejemplo, 

Apellido Longitud 
Abel     4
*/

SELECT DISTINCT

-- desde la vista de Empleados, se obtiene el apellido de cada uno

HRvE.LastName AS 'Apellido de contacto',
LEN(HRvE.LastName) AS 'Longitud' -- con LEN se obtiene la cantidad de caracteres

FROM HumanResources.vEmployee AS HRvE

ORDER BY HRvE.LastName


/*
9. Realizar una consulta que permita encontrar el apellido con mayor longitud.
*/

SELECT TOP 1 

HRvE.LastName AS 'Apellido mas largo (Vista vEmployee)',
LEN(HRvE.LastName) AS 'Longitud'

FROM HumanResources.vEmployee AS HRvE

ORDER BY LEN(HRvE.LastName) DESC


SELECT TOP 1

Person.Person.LastName AS 'Apellido mas largo (Tabla Person.Person)',
LEN(Person.Person.LastName) AS 'Longitud'

FROM Person.Person

ORDER BY LEN(Person.LastName) DESC


/*
10.Realizar una consulta que devuelva los nombres y apellidos de los contactos que hayan sido modificados en los últimos 3 años.
*/


-- dado que las actividades se realizan sobre la base de datos de práctica Adventure Works 2014,
-- a la fecha (Diciembre 2025) la consulta no devuelve resultados con valores menores a 10

SELECT

PP.FirstName AS 'Nombre',
PP.LastName AS 'Apellido',
PP.ModifiedDate AS 'Fecha de ultima modificacion'

FROM Person.Person AS PP

WHERE DATEDIFF(YEAR, PP.ModifiedDate, GETDATE()) <= 10


/*
11.Se quiere obtener los emails de todos los contactos, pero en mayúscula.
*/

SELECT

UPPER(PEA.EmailAddress) AS 'Direccion de Email de contactos (Mayuscula)'

FROM Person.EmailAddress AS PEA


/*
12.Realizar una consulta que permita particionar el mail de cada contacto, obteniendo lo siguiente: 
ID Contacto email            nombre      Dominio 
       1    juanp@ibm.com    juanp       ibm
*/

SELECT

PEA.BusinessEntityID AS 'ID Contacto',
PEA.EmailAddress AS 'Email',

-- Para obtener el particionado correcto se usa CHARINDEX para saber la posicion
-- del caracter '@', el nombre termina en la posicion anterior al mismo y por ello
-- se resta en 1 la posicion.

-- El mismo criterio se aplica para el caso del dominio, solo que se suma en 1 para
-- obtener todo lo que se encuentre luego de la posicion del caracter '@'

SUBSTRING(PEA.EmailAddress, 1, CHARINDEX('@', PEA.EmailAddress, 1) - 1) AS 'Nombre',
SUBSTRING(PEA.EmailAddress, CHARINDEX('@', PEA.EmailAddress) + 1, 100) AS 'Dominio'

FROM Person.EmailAddress AS PEA

ORDER BY PEA.BusinessEntityID


/*
13. Devolver los últimos 3 dígitos del NationalIDNumber de cada empleado
*/

SELECT

HRE.BusinessEntityID AS 'ID empleado',
RIGHT(HRE.NationalIDNumber, 3) AS 'Ultimos 3 digitos de National ID Number'

FROM HumanResources.Employee AS HRE

ORDER BY HRE.BusinessEntityID


/*
14.Se desea enmascarar el NationalIDNumbre de cada empleado, de la siguiente forma ###-####-##: 

ID Numero    Enmascarado 
36 113695504 113-6955-04
*/

SELECT

HRE.BusinessEntityID AS 'ID empleado',
HRE.NationalIDNumber AS 'National ID Number original',
CONCAT(
    
    LEFT(HRE.NationalIDNumber, 3),
    '-',
    SUBSTRING(HRE.NationalIDNumber, 4, 4),
    '-',
    SUBSTRING(HRE.NationalIDNumber, 8, 100)
    ) AS 'National ID Number enmascarado'

FROM HumanResources.Employee AS HRE

ORDER BY HRE.BusinessEntityID


/*
15. Listar la dirección de cada empleado “supervisor” que haya nacido hace más de 30 años. Listar todos los datos en mayúscula.
Los datos a visualizar son: nombre y apellido del empleado, dirección y ciudad.
*/

SELECT

UPPER(HRvE.FirstName) AS 'Nombre',
UPPER(HRvE.LastName) AS 'Apellido',
UPPER(HRvE.AddressLine1) AS 'Direccion 1',
UPPER(HRvE.AddressLine2) AS 'Direccion 2',
UPPER(HRvE.City) AS 'Ciudad',
UPPER(HRE.JobTitle) AS 'Puesto'

FROM HumanResources.vEmployee AS HRvE

JOIN HumanResources.Employee AS HRE ON HRvE.BusinessEntityID = HRE.BusinessEntityID

WHERE HRE.JobTitle LIKE '%supervisor%' AND DATEDIFF(YEAR, HRE.BirthDate, GETDATE()) > 30

ORDER BY HRvE.BusinessEntityID


/*
16. Listar la cantidad de empleados hombres y mujeres, de la siguiente forma: 
Sexo      Cantidad 
Femenino  47 
Masculino 56
Nota: Debe decir, Femenino y Masculino de la misma forma que se muestra.
*/

SELECT

-- el CASE en este caso se aplica para poder mostrar el nombre de columna tal cual como lo pide la consigna
CASE
    WHEN HRE.Gender = 'F' THEN 'Femenino'
    ELSE 'Masculino'
END AS 'Sexo',
COUNT(HRE.BusinessEntityID) AS 'Cantidad'

FROM HumanResources.Employee AS HRE

GROUP BY HRE.Gender


/*
17.Categorizar a los empleados según la cantidad de horas de vacaciones, según el siguiente formato: 
Alto = más de 50 / medio= entre 20 y 50 / bajo = menos de 20
*/

SELECT

HRE.BusinessEntityID AS 'ID empleado',
CASE
    WHEN HRE.VacationHours > 50 THEN 'Alto'
    WHEN HRE.VacationHours BETWEEN 20 AND 50 THEN 'Medio'
    ELSE 'Bajo'
END AS 'Horas de vacaciones'

FROM HumanResources.Employee AS HRE

ORDER BY HRE.BusinessEntityID