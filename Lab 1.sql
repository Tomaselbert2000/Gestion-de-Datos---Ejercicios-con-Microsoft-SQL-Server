USE AdventureWorks2014;

-- para aportar claridad a los resultados, todas las consultas filtrarán por resultados solo en Ingles

/*
1- Listar los códigos y descripciones de todos los productos (Ayuda: Production.Product)
*/

SELECT

-- para obtener la descripciones, se hace JOIN desde Productos por medio de ProductModelProductDescriptionCulture (se usa el nro de modelo)

P.ProductID AS 'ID Producto',
PD.Description AS 'Descripcion'

FROM Production.Product AS P

-- estos JOIN son INNER JOINs implicitos, no van a traer aquellos que sean NULL

JOIN Production.ProductModelProductDescriptionCulture AS PMPDC ON P.ProductModelID = PMPDC.ProductModelID
JOIN Production.ProductDescription AS PD ON PMPDC.ProductDescriptionID = PD.ProductDescriptionID

WHERE PMPDC.CultureID = 'en'

ORDER BY P.ProductID


/*
2- Listar los datos de la subcategoría número 17 (Ayuda: Production.ProductSubCategory)
*/

SELECT

-- en esta consulta se omite el campo de rowguid ya que es innecesario en este caso

PSC.ProductSubcategoryID AS 'ID subcategoria',
PSC.ProductCategoryID AS 'ID categoria',
PSC.Name AS 'Nombre',
PSC.ModifiedDate AS 'Fecha de modificacion'

FROM Production.ProductSubcategory AS PSC

WHERE PSC.ProductSubcategoryID = 17 -- se filtra con el WHERE para traer solamente la que tenga el ID requerido


/*
3- Listar los productos cuya descripción comience con D (Ayuda: like ‘D%’)
*/

SELECT

-- se recicla codigo anterior, se agrega el condicional de la inicial en la descripcion

P.ProductID AS 'ID Producto',
P.Name AS 'Nombre',
P.ProductModelID AS 'Modelo',
PD.Description AS 'Descripcion (filtrada por inicial: D)'

FROM Production.Product AS P

JOIN Production.ProductModelProductDescriptionCulture AS PMPDC ON P.ProductModelID = PMPDC.ProductModelID
JOIN Production.ProductDescription AS PD ON PMPDC.ProductDescriptionID = PD.ProductDescriptionID

WHERE PD.Description LIKE 'D%' AND PMPDC.CultureID = 'en' -- con la clausula LIKE se limita a que se muestren solo aquellas que empiezan con D

ORDER BY P.ProductID

/*
4- Listar las descripciones de los productos cuyo número finalice con 8 (Ayuda: ProductNumber like ‘%8’)
*/

-- similar al ejercicio anterior, tambien vamos a usar LIKE

SELECT

P.ProductID AS 'ID Producto',
P.Name AS 'Nombre',
P.ProductModelID AS 'Modelo',
P.ProductNumber AS 'Numero de producto', -- a efectos practicos se agrega el campo ProductNumber en el SELECT
PD.Description AS 'Descripcion (filtrada por numero finalizado en 8)'

FROM Production.Product AS P

JOIN Production.ProductModelProductDescriptionCulture AS PMPDC ON P.ProductModelID = PMPDC.ProductModelID
JOIN Production.ProductDescription AS PD ON PMPDC.ProductDescriptionID = PD.ProductDescriptionID

WHERE P.ProductNumber LIKE '%8' AND PMPDC.CultureID = 'en' -- se filtran y muestran solo aquellos terminados en 8

ORDER BY P.ProductID


/*
5- Listar aquellos productos que posean un color asignado.
Se deberán excluir todos aquellos que no posean ningún valor (Ayuda: is not null)
*/

SELECT

P.ProductID AS 'ID Producto',
P.Name AS 'Nombre',
-- a efectos practicos se muestra el color, aunque ciertos registros lo mencionan en el nombre tambien
P.Color AS 'Color asignado'
FROM Production.Product AS P

-- dentro de la clausula WHERE se filtra por aquellos registros que no tengan NULL en la columna del color
WHERE P.Color IS NOT NULL

ORDER BY P.ProductID


/*
6- Listar el código y descripción de los productos de color Black (Negro) y que posean el nivel de stock en 500. (Ayuda: SafetyStockLevel = 500)
*/

SELECT

P.ProductID AS 'ID Producto',
P.Color AS 'Color',
P.SafetyStockLevel AS 'Nivel de stock',
PD.Description AS 'Descripcion'

FROM Production.Product AS P

JOIN Production.ProductModelProductDescriptionCulture AS PMPDC ON P.ProductModelID = PMPDC.ProductModelID
JOIN Production.ProductDescription AS PD ON PMPDC.ProductDescriptionID = PD.ProductDescriptionID

-- dentro del WHERE se filtra tanto por color, como aquellos que tengan 500 o mas en el valor de stock
WHERE P.Color = 'Black' AND P.SafetyStockLevel = 500 AND PMPDC.CultureID = 'en'

ORDER BY P.ProductID


/*
7- Listar los productos que sean de color Black (Negro) ó Silver (Plateado).
*/

SELECT

P.ProductID AS 'ID Producto',
P.Color AS 'Color asignado (solo Silver o Black)'

FROM Production.Product AS P

WHERE P.Color IN ('Black', 'Silver')

ORDER BY P.ProductID


/*
8- Listar los diferentes colores que posean asignados los productos. Sólo se deben listar los colores. (Ayuda: distinct)
*/

SELECT DISTINCT -- se seleccionan solo los registros distintos, es decir, si alguno se repite, se mostrará una sola vez

P.Color AS 'Colores asignados a productos'

FROM Production.Product AS P

WHERE P.Color IS NOT NULL -- y se filtra para que no muestre campos en NULL


/*
9- Contar la cantidad de categorías que se encuentren cargadas en la base. (Ayuda: count)
*/

SELECT

-- se cuenta la cantidad de claves primarias de categorias
COUNT(Production.ProductCategory.ProductCategoryID) AS 'Cantidad de categorias cargadas'

FROM Production.ProductCategory;


/*
10- Contar la cantidad de subcategorías que posee asignada la categoría 2.
*/

SELECT

-- se cuentan las claves primarias
COUNT(PSC.ProductSubcategoryID) AS 'Cantidad de subcategorias asociadas a categoria 2'

FROM Production.ProductSubcategory AS PSC

WHERE PSC.ProductCategoryID = 2; -- y se filtran las que referencian a la categoria 2


/*
11- Listar la cantidad de productos que existan por cada uno de los colores.
*/

SELECT

-- se muestra cada color y se cuentan las claves primarias de productos

P.Color AS 'Color', 
COUNT(P.ProductID) AS 'Cantidad' 

FROM Production.Product AS P

WHERE P.Color IS NOT NULL -- se filtran nulos antes de agrupar

GROUP BY P.Color -- se agrupa por cada color encontrado para obtener su total de productos

ORDER BY P.Color


/*
12- Sumar todos los niveles de stocks aceptables que deben existir para los productos con color Black. (Ayuda: sum)
*/

SELECT

-- la funcion SUM acumula el total de stock de productos
SUM(P.SafetyStockLevel) AS 'Suma stock productos Black'

FROM Production.Product AS P

WHERE P.Color = 'Black' -- y en esta linea se descartan los que no sean Black


/*
13- Calcular el promedio de stock que se debe tener de todos los productos cuyo código se encuentre entre el 316 y 320. (Ayuda: avg)
*/

SELECT

-- con AVG se obtiene el promedio de stock de los productos
AVG(P.SafetyStockLevel) AS 'Promedio de stock - ID 316~320'

FROM Production.Product AS P

-- y la clausula BETWEEN descarta aquellos que esten fuera del rango (BETWEEN es lo mismo a 'menor/mayor o igual')
WHERE P.ProductID BETWEEN 316 AND 320;


/*
14- Listar el nombre del producto y descripción de la subcategoría que posea asignada. (Ayuda: inner join)
*/

SELECT

P.Name AS 'Nombre producto',
PSC.Name AS 'Descripcion subcategoria'

FROM Production.Product AS P

-- el INNER JOIN solo trae coincidencias si ambas tablas tienen los mismos datos, por lo tanto funciona tambien como filtro, similar a WHERE

INNER JOIN Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID

ORDER BY P.Name


/*
15- Listar todas las categorías que poseen asignado al menos una subcategoría. Se deberán excluir aquellas que no posean ninguna.
*/

SELECT

PC.Name AS 'Categorias con al menos una subcategoria'

FROM Production.ProductCategory AS PC

WHERE PC.ProductCategoryID IN (SELECT PSC.ProductCategoryID FROM Production.ProductSubcategory AS PSC)


/*
16- Listar el código y descripción de los productos que posean fotos asignadas. (Ayuda: Production.ProductPhoto)
*/

SELECT

P.ProductID AS 'ID Producto',
PD.[Description] AS 'Descripcion',
PH.LargePhoto AS 'Imagen'

FROM Production.Product AS P

-- dado que se piden solo los que tengan fotos asignadas, el INNER JOIN implicito filtra los que no tengan coincidencias, se omite el WHERE

JOIN Production.ProductModelProductDescriptionCulture AS PMPDC ON P.ProductModelID = PMPDC.ProductModelID
JOIN Production.ProductDescription AS PD ON PMPDC.ProductDescriptionID = PD.ProductDescriptionID
JOIN Production.ProductProductPhoto AS PPH ON P.ProductID = PPH.ProductID -- este JOIN obtiene la coincidencia entre el producto y su ID de foto
JOIN Production.ProductPhoto AS PH ON PPH.ProductPhotoID = PH.ProductPhotoID -- mientras este otro obtiene el recurso de foto asociado a ese ID

WHERE PMPDC.CultureID = 'en'

ORDER BY P.ProductID;


/*
17- Listar la cantidad de productos que existan por cada una de las Clases (Ayuda: campo Class)
*/

SELECT

P.Class AS 'Clase producto', -- se categoriza por clase
COUNT(P.ProductID) AS 'Cantidad' -- se cuentan todos los objetos

FROM Production.Product AS P

WHERE P.Class IS NOT NULL -- antes de agrupar se descartan los que sean NULL

GROUP BY P.Class

ORDER BY P.Class;


/*
18- Listar la descripción de los productos y su respectivo color. 
Sólo nos interesa caracterizar al color con los valores: Black, Silver u Otro.
Por lo cual si no es ni silver ni black se debe indicar Otro. (Ayuda: utilizar case).
*/

SELECT

P.ProductID AS 'ID Producto',
CASE 
    WHEN P.Color IN ('Black', 'Silver') THEN P.Color
    ELSE 'Otro'
END AS 'Color',
PD.[Description] AS 'Descripcion'

FROM Production.Product AS P

JOIN Production.ProductModelProductDescriptionCulture AS PMPDC ON P.ProductModelID = PMPDC.ProductModelID
JOIN Production.ProductDescription AS PD ON PMPDC.ProductDescriptionID = PD.ProductDescriptionID

WHERE PMPDC.CultureID = 'en'

ORDER BY P.ProductID;


/*
19- Listar el nombre de la categoría, el nombre de la subcategoría y la descripción del producto. (Ayuda: join)
*/

SELECT

P.ProductID AS 'ID Producto',
P.Name AS 'Nombre',
PC.Name AS 'Categoria',
PSC.Name AS 'Subcategoria',
PD.[Description] AS 'Descripcion'

FROM Production.Product AS P

-- el uso de INNER JOINs implicitos ya filtra aquellos registros sin coincidencias totales, no es necesario el WHERE en este caso
JOIN Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN Production.ProductCategory AS PC ON PSC.ProductCategoryID = PC.ProductCategoryID
JOIN Production.ProductModelProductDescriptionCulture AS PMPDC ON P.ProductModelID = PMPDC.ProductModelID
JOIN Production.ProductDescription AS PD ON PMPDC.ProductDescriptionID = PD.ProductDescriptionID

WHERE PMPDC.CultureID = 'en'

ORDER BY P.ProductID;


/*
20- Listar la cantidad de subcategorías que posean asignado los productos. (Ayuda: distinct).
*/

SELECT 

-- dentro de la funcion COUNT se especifica con DISTINCT que no se traigan valores repetidos en la consulta

COUNT(DISTINCT Production.Product.ProductSubcategoryID) AS 'Cantidad de subcategorias asignadas a productos'

FROM Production.Product;