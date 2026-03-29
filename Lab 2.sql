USE AdventureWorks2014;

/*
1. Listar los nombres de los productos y el nombre del modelo que posee asignado. Solo listar aquellos que tengan asignado algún modelo.
*/

SELECT

P.Name AS 'Producto',
PM.Name AS 'Modelo'

FROM Production.Product AS P

-- usar JOIN acá filtra todos los que no tengan modelo asignado

JOIN Production.ProductModel AS PM ON P.ProductModelID = PM.ProductModelID

ORDER BY P.Name;


/*
2. Mostrar “todos” los productos junto con el modelo que tenga asignado.
En el caso que no tenga asignado ningún modelo, mostrar su nulidad.
*/

-- el código es similar al ejercicio anterior, con la diferencia en el JOIN usado
-- dado que se especifica "todos", se usar LEFT JOIN para incluir aquellos que sean NULL

SELECT

P.ProductID AS 'ID Producto',
P.Name AS 'Nombre',
PM.Name AS 'Modelo (incluyendo NULLs)'

FROM Production.Product AS P

-- usar JOIN acá filtra todos los que no tengan modelo asignado

LEFT JOIN Production.ProductModel AS PM ON P.ProductModelID = PM.ProductModelID

ORDER BY P.ProductID;


/*
3. Ídem Ejercicio2, pero en lugar de mostrar nulidad, mostrar la palabra “Sin Modelo” para indicar que el producto no posee un modelo asignado.
*/

-- para poder mostrar el mensaje requerido, es necesario traer los NULLs que existan en la consulta con LEFT JOIN y luego un CASE WHEN gestiona si mostrar el mensaje o no

SELECT

P.ProductID AS 'ID Producto',
P.Name AS 'Nombre',
CASE
    WHEN P.ProductModelID IS NULL THEN 'Sin modelo'
    ELSE PM.Name
END AS 'Modelo'

FROM Production.Product AS P

LEFT JOIN Production.ProductModel AS PM ON P.ProductModelID = PM.ProductModelID

ORDER BY P.ProductID;


/*
4. Contar la cantidad de Productos que poseen asignado cada uno de los modelos.
*/

SELECT

PM.Name AS 'Modelo',
COUNT(P.ProductID) AS 'Cantidad de productos asignada' -- se cuenta la cantidad de claves primarias

FROM Production.ProductModel AS PM

JOIN Production.Product AS P ON PM.ProductModelID = P.ProductModelID

GROUP BY PM.Name -- la clausula GROUP BY agrupa por nombre de modelo y devuelve la cantidad para cada uno de ellos

ORDER BY PM.Name;


/*
5. Contar la cantidad de Productos que poseen asignado cada uno de los modelos, pero mostrar solo aquellos modelos que posean asignados 2 o más productos.
*/

-- se recicla el código del ejercicio anterior dada la similitud, se agrega el condicional necesario para la cantidad

SELECT

PM.Name AS 'Modelo',
COUNT(P.ProductID) AS 'Cantidad de productos asignada (minimo 2)'

FROM Production.ProductModel AS PM

JOIN Production.Product AS P ON PM.ProductModelID = P.ProductModelID

GROUP BY PM.Name

HAVING COUNT(P.ProductID) >= 2 -- luego de realizar el agrupamiento, la clausula HAVING descarta aquellos resultados de COUNT que sean menores que 2

ORDER BY PM.Name;


/*
6. Contar la cantidad de Productos que poseen asignado un modelo valido, es decir, que se encuentre cargado en la tabla de modelos.
Realizar este ejercicio de 3 formas posibles: “exists” / “in” / “inner join”.
*/

-- ejercicio realizado con IN

SELECT

COUNT(P.ProductID) AS 'Cantidad de productos con modelo asignado (IN)'

FROM Production.Product AS P

/*
en el WHERE se usa una subconsulta que obtiene todos los ID de modelo registrados en la tabla ProductModel
y con la clausula IN, el WHERE va a filtrar todos los ModelID que no se encuentren dentro de esa subconsulta
*/

WHERE P.ProductModelID IN (SELECT PM.ProductModelID FROM Production.ProductModel AS PM)


-- ejercicio realizado con INNER JOIN

SELECT

COUNT(P.ProductID) AS 'Cantidad de productos con modelo asignado (INNER JOIN)'

FROM Production.Product AS P

-- el INNER JOIN filtra directamente los registros de productos que si tienen coincidencia con la tabla de modelos
INNER JOIN Production.ProductModel AS PM ON P.ProductModelID = PM.ProductModelID


-- ejercicio realizado con EXISTS

SELECT

COUNT (P.ProductID) AS 'Cantidad de productos con modelo asignado (EXISTS)'

FROM Production.Product AS P

/*
De manera similar al ejercicio con IN, en este caso la subconsulta trae todos los ID de modelos desde la tabla
y cuenta solo los productos cuyo model ID si exista dentro de la subconsulta dada
*/

WHERE EXISTS (SELECT PM.ProductModelID FROM Production.ProductModel AS PM WHERE P.ProductModelID = PM.ProductModelID)


/*
7. Contar cuantos productos poseen asignado cada uno de los 
modelos, es decir, se quiere visualizar el nombre del modelo y 
la cantidad de productos asignados. Si algún modelo no posee 
asignado ningún producto, se quiere visualizar 0 (cero).
*/

SELECT

PM.Name AS 'Modelo',
COUNT(P.ProductID) AS 'Cantidad de productos'

FROM Production.ProductModel AS PM

-- en este caso se usa LEFT JOIN para traer todos los registros, si alguno es NULL, la funcion COUNT automaticamente muestra el valor 0 requerido en la consigna
LEFT JOIN Production.Product AS P ON PM.ProductModelID = P.ProductModelID

GROUP BY PM.Name

ORDER BY PM.Name;


/*
8. Se quiere visualizar, el nombre del producto, el nombre 
modelo que posee asignado, la ilustración que posee asignada 
y la fecha de última modificación de dicha ilustración y el 
diagrama que tiene asignado la ilustración. Solo nos interesan 
los productos que cuesten más de $150 y que posean algún 
color asignado.
*/

SELECT

P.ProductID AS 'ID producto',
P.Name AS 'Nombre',
P.Color AS 'Color',
P.ListPrice AS 'Precio de lista',
PM.Name AS 'Modelo',
PI.IllustrationID AS 'ID ilustracion',
PI.Diagram AS 'Diagrama de ilustracion',
PI.ModifiedDate AS 'Fecha de modificacion de ilustracion'

FROM Production.Product AS P

JOIN Production.ProductModel AS PM ON P.ProductModelID = PM.ProductModelID
JOIN Production.ProductModelIllustration AS PMI ON PM.ProductModelID = PMI.ProductModelID
JOIN Production.Illustration AS PI ON PMI.IllustrationID = PI.IllustrationID

-- el condicional filtra todos los que estén por debajo de 150 y no tengan color
WHERE P.ListPrice >= 150.0 AND P.Color IS NOT NULL

ORDER BY P.ProductID;


/*
9. Mostrar aquellas culturas que no están asignadas a ningún producto/modelo. (Production.ProductModelProductDescriptionCulture)
*/

SELECT

PC.Name AS 'Culturas no asignadas a ningun producto/modelo'

FROM Production.Culture AS PC

-- dentro de una subconsulta se traen todos los CultureID que si están asignados desde la tabla que gestiona la asignacion del mismo
-- y el WHERE filtra para mostrar solo los que no estén dentro de esa subconsulta

WHERE PC.CultureID NOT IN (SELECT PMPDC.CultureID FROM Production.ProductModelProductDescriptionCulture AS PMPDC)

ORDER BY PC.Name


/*
10. Agregar a la base de datos el tipo de contacto “Ejecutivo de Cuentas” (Person.ContactType)
*/

INSERT INTO Person.ContactType(Name)
VALUES ('Ejecutivo de Cuentas')


/*
11. Agregar la cultura llamada “nn” – “Cultura Moderna”.
*/

INSERT INTO Production.Culture(CultureID, Name)
VALUES ('nn', 'Cultura Moderna')


/*
12. Cambiar la fecha de modificación de las culturas Spanish, French y Thai para indicar que fueron modificadas hoy.
*/

SELECT * FROM Production.Culture

UPDATE Production.Culture

-- llamando a GETDATE se obtiene la fecha actual al momento de correr la consulta

SET ModifiedDate = DATEFROMPARTS(DATEPART(YEAR, GETDATE()), DATEPART(MONTH, GETDATE()), DATEPART(DAY, GETDATE()))

-- y con IN se especifican todos los ID que deben ser alcanzados por la actualizacion

WHERE CultureID IN ('es', 'fr', 'th')


/*
13. En la tabla Production.CultureHis agregar todas las culturas que fueron modificadas hoy. (Insert/Select).
*/

-- dado el orden en el que se plantean los ejercicios, la tabla CultureHis no existe en este punto
-- ya que se creará mediante un Stored Procedure en otra actividad, se dispone la consulta acorde
-- a los datos que deberá tener esa tabla cuando sea creada

INSERT INTO Production.CultureHis(CultureID, Name, ModifiedDate)

-- con la consulta SELECT se trasladan de manera directa los datos desde una tabla hacia otra
SELECT 

PC.CultureID, PC.Name, PC.ModifiedDate 

FROM Production.Culture AS PC 

WHERE PC.ModifiedDate = DATEFROMPARTS(DATEPART(YEAR, GETDATE()), DATEPART(MONTH, GETDATE()), DATEPART(DAY, GETDATE()))


/*
14. Al contacto con ID 10 colocarle como nombre “Juan Perez”.
*/

UPDATE Person.Person

SET FirstName = 'Juan', LastName = 'Perez'

WHERE Person.BusinessEntityID = 10


/*
15. Agregar la moneda “Peso Argentino” con el código “PAR” (Sales.Currency)
*/

INSERT INTO Sales.Currency(CurrencyCode, Name)

VALUES ('PAR', 'Peso Argentino')


/*
16. ¿Qué sucede si tratamos de eliminar el código ARS correspondiente al Peso Argentino? ¿Por qué?
*/

DELETE FROM Sales.Currency

WHERE CurrencyCode = 'ARS'

-- al intentar ejecutar esta consulta, genera un error debido a que existen referencias al registro que se intenta eliminar
-- de no borrar primero esas referencias, la tabla no permite quitar el registro que pide la consigna


/*
17. Realice los borrados necesarios para que nos permita eliminar el registro de la moneda con código ARS.
*/

EXECUTE sp_help 'Sales.Currency'

/*
Al ejecutar este SP, se obtiene que la tabla es referenciada en:
- Sales.CountryRegionCurrency --> CurrencyRate_Currency_FromCurrencyCode
- Sales.CurrencyRate --> FromCurrencyCode
- Sales.CurrencyRate --> ToCurrencyCode
Por lo tanto se eliminan los tres registros relacionados y luego
de eso, se procede a eliminar el registro de la consigna
*/

DELETE FROM Sales.CountryRegionCurrency
WHERE CurrencyCode = 'ARS'

DELETE FROM Sales.CurrencyRate
WHERE FromCurrencyCode = 'ARS' OR ToCurrencyCode = 'ARS'

DELETE FROM Sales.Currency
WHERE CurrencyCode = 'ARS'


/*
18. Eliminar aquellas culturas que no estén asignadas a ningún producto (Production.ProductModelProductDescriptionCulture)
*/

DELETE FROM Production.Culture

WHERE Production.Culture.CultureID NOT IN (
        -- la subconsulta trae todos los registros de CultureID asignados, se eliminan las culturas que no se encuentren entre los resultados
        SELECT PMPDC.CultureID FROM Production.ProductModelProductDescriptionCulture AS PMPDC
    )