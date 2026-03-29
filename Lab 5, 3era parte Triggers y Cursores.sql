USE AdventureWorks2014

CREATE TABLE Person.EmailAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    BusinessEntityID INT,
    OldEmail NVARCHAR(50),
    NewEmail NVARCHAR(50),
    ChangeDate DATETIME DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(50)
)
GO


/*
tr_CheckProductStatus (Validación Preventiva):

Crea un trigger INSTEAD OF INSERT en la tabla Sales.SalesOrderDetail.

Lógica: Antes de permitir la venta de un producto, el trigger debe consultar la tabla Production.Product.

Condición: Si la fecha actual es mayor a la SellEndDate del producto (es decir, el producto está descatalogado),
la inserción debe cancelarse con un error: "Error: No se pueden vender productos cuya fecha de venta ha expirado."

Acción: Si el producto es válido, el trigger debe completar la inserción manualmente (ya que es un INSTEAD OF).
*/

CREATE TRIGGER tr_CheckProductStatus

ON Sales.SalesOrderDetail INSTEAD OF INSERT
AS
BEGIN

    SET NOCOUNT ON
    
    BEGIN

            BEGIN TRY

                BEGIN TRANSACTION

                    INSERT INTO Sales.SalesOrderDetail(SalesOrderID, OrderQty, ProductID, UnitPrice)

                    SELECT 
                    
                    I.SalesOrderID,
                    I.OrderQty,
                    I.ProductID

                    FROM inserted AS I

                    JOIN Production.Product AS P ON I.ProductID = P.ProductID

                    WHERE P.SellEndDate >= GETDATE()

                COMMIT TRANSACTION

            END TRY

            BEGIN CATCH

                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
                THROW

            END CATCH

        END
    
END
GO


/*
tr_AuditEmailChanges (Auditoría de Contacto):

Crea un trigger AFTER UPDATE en la tabla Person.EmailAddress.

Condición: Debe activarse solo si cambia la columna EmailAddress.

Acción: Insertar un registro en Person.EmailAudit guardando el ID del usuario, el email anterior, el nuevo y quién realizó el cambio (SYSTEM_USER).
*/

CREATE TRIGGER tr_AuditEmailChanges

ON Person.EmailAddress AFTER UPDATE
AS
BEGIN

    SET NOCOUNT ON

    IF UPDATE(EmailAddress)
    BEGIN

        BEGIN TRY

            INSERT INTO Person.EmailAudit(BusinessEntityID, OldEmail, NewEmail, ModifiedBy)

            SELECT

            D.BusinessEntityID,
            D.EmailAddress,
            I.EmailAddress,
            SYSTEM_USER

            FROM deleted AS D

            JOIN inserted AS I ON D.BusinessEntityID = I.BusinessEntityID

        END TRY

        BEGIN CATCH

            THROW

        END CATCH

    END
END
GO


/*
Cursor de Resumen de Ventas por Territorio:

Crea un cursor que recorra la tabla Sales.SalesTerritory.

Acción: Por cada territorio, debe calcular la suma total de SalesYTD (Ventas del año actual) de todos los vendedores (Sales.SalesPerson) asignados a ese territorio.

Salida: Imprimir un mensaje con el formato: "Territorio: [Nombre] - Ventas Totales del Equipo: $[SumaCalculada]"

Pista: Necesitarás una variable para acumular la suma dentro del bucle del cursor.
*/

DECLARE cr_SalesSalesTerritory CURSOR

FOR SELECT 
    
    SST.TerritoryID,
    SST.Name

    FROM Sales.SalesTerritory AS SST

DECLARE @idTerritorio INT, @nombreTerritorio NAME, @acumuladorAuxiliar MONEY = 0

OPEN cr_SalesSalesTerritory

FETCH NEXT FROM cr_SalesSalesTerritory INTO @idTerritorio, @nombreTerritorio

WHILE @@FETCH_STATUS = 0

BEGIN

    IF ((SELECT SUM(SSP.SalesYTD) FROM Sales.SalesPerson AS SSP WHERE SSP.TerritoryID = @idTerritorio)) IS NOT NULL

    BEGIN

        SET @acumuladorAuxiliar += 
    
            (SELECT
            
            SUM(SSP.SalesYTD) FROM Sales.SalesPerson AS SSP

            WHERE SSP.TerritoryID = @idTerritorio)

            PRINT CONCAT('Territorio: ', @nombreTerritorio, 'Ventas totales del equipo: $ ', @acumuladorAuxiliar)

            SET @acumuladorAuxiliar = 0

            FETCH NEXT FROM cr_SalesSalesTerritory INTO @idTerritorio, @nombreTerritorio

    END
    ELSE

        SET @acumuladorAuxiliar = 0
        
        PRINT CONCAT('Territorio: ', @nombreTerritorio, 'Ventas totales del equipo: $ ', @acumuladorAuxiliar)

        FETCH NEXT FROM cr_SalesSalesTerritory INTO @idTerritorio, @nombreTerritorio
END

CLOSE cr_SalesSalesTerritory

DEALLOCATE cr_SalesSalesTerritory

GO


/*
Cursor de Actualización de Precios por Categoría:

Crea un cursor que recorra los productos de la categoría 'Components' (necesitarás unir Production.Product, Production.ProductSubcategory y Production.ProductCategory).

Acción: Para cada producto de esa categoría, imprimir: "Actualizando precio de: [Nombre]. Precio anterior: [ListPrice]."

Nota: En este ejercicio solo imprimiremos los cambios simulados para practicar la navegación por múltiples tablas.
*/

DECLARE cr_ActualizacionPreciosCategoria CURSOR

FOR SELECT

    P.ProductID,
    P.Name,
    P.ListPrice,
    PSC.ProductSubcategoryID,
    PC.ProductCategoryID

    FROM Production.Product AS P

    JOIN Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC ON PSC.ProductCategoryID = PC.ProductCategoryID

    WHERE PC.Name = 'Components'

DECLARE @idProducto INT, @nombreProducto NAME, @precioLista MONEY, @idSubcat INT, @idCat INT

OPEN cr_ActualizacionPreciosCategoria

FETCH NEXT FROM cr_ActualizacionPreciosCategoria INTO @idProducto, @nombreProducto, @precioLista, @idSubcat, @idCat

WHILE @@FETCH_STATUS = 0
BEGIN

    PRINT CONCAT('ID producto: ', @idProducto, 'ID subcategoria', @idSubcat, 'ID categoria', @idCat,' Nombre: ', @nombreProducto, ' Precio anterior: ', @precioLista)

    FETCH NEXT FROM cr_ActualizacionPreciosCategoria INTO @idProducto, @nombreProducto, @precioLista, @idSubcat, @idCat
END

CLOSE cr_ActualizacionPreciosCategoria

DEALLOCATE cr_ActualizacionPreciosCategoria

GO
