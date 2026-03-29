USE AdventureWorks2014

-- creacion de tabla de auditoria de productos

CREATE TABLE Production.ProductAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    Operation NVARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    AuditDate DATETIME DEFAULT GETDATE(),
    UserInfo NVARCHAR(50),
    OldListPrice MONEY NULL, -- Para guardar el precio anterior
    NewListPrice MONEY NULL  -- Para guardar el precio nuevo
);
GO

/*
2. tr_Product_Insert (Trigger AFTER INSERT):

Crea un trigger en la tabla Production.Product que se dispare después de insertar un nuevo producto.
Acción: Debe insertar un registro en Production.ProductAudit.
Datos a guardar: ProductID (del nuevo producto), Operation = 'INSERT', UserInfo = usuario actual (usar SYSTEM_USER), y los precios en NULL.
*/

CREATE TRIGGER tr_Product_Insert

ON Production.Product AFTER INSERT -- se define la tabla donde se ubica el trigger y el tipo
AS
BEGIN

    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION -- dado que se trata de una insercion, se abre una nueva transaccion

            INSERT INTO Production.ProductAudit(ProductID, Operation, UserInfo, OldListPrice, NewListPrice) -- se inserta en la lista un select directamente desde los datos nuevos

            SELECT inserted.ProductID, 'INSERT', SYSTEM_USER, NULL, NULL FROM inserted

        COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
        
        -- ante cualquier error, se hace rollback

        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW

    END CATCH

END
GO

/*
3. tr_Product_UpdatePrice (Trigger AFTER UPDATE): Crea un trigger en la tabla Production.Product que se active después de una actualización.

Condición: El trigger debe ejecutarse solo si se modificó la columna ListPrice. (Investiga la función UPDATE(columna)).

Acción: Registrar en Production.ProductAudit.

Datos a guardar: ProductID, Operation = 'UPDATE', UserInfo, OldListPrice (valor antes del cambio), NewListPrice (valor nuevo).

Ayuda: Recuerda que DELETED tiene los valores viejos e INSERTED los nuevos.
*/

CREATE TRIGGER tr_Product_UpdatePrice

ON Production.Product AFTER UPDATE
AS
BEGIN

    SET NOCOUNT ON

    IF UPDATE(ListPrice) -- esto retorna true o false segun si el campo ingresado se encontraba en la consulta original de actualizacion
    
    BEGIN

        BEGIN TRY

            BEGIN TRANSACTION

                -- con el SELECT se traslada de manera directa los datos, el precio viejo en Deleted y el nuevo en Inserted tambien se seleccionan

                INSERT INTO Production.ProductAudit(ProductID, Operation, UserInfo, OldListPrice, NewListPrice)

                SELECT 
                
                inserted.ProductID,
                'UPDATE',
                SYSTEM_USER,
                deleted.ListPrice,
                inserted.ListPrice 
                
                FROM inserted
                
                -- se hace JOIN entre ambas tablas virtuales y se compara el ListPrice
                -- para validar que realmente cambió y que no se ingresó como nuevo el mismo valor
                JOIN deleted ON inserted.ProductID = deleted.ProductID

                WHERE inserted.ListPrice <> deleted.ListPrice

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
4. tr_Prevent_Delete (Trigger INSTEAD OF DELETE):
Crea un trigger en la tabla Production.ProductReview (Reseñas de productos).

Lógica: Por políticas de la empresa, no se permite borrar reseñas físicamente.
Acción: Si alguien intenta hacer un DELETE sobre esta tabla, el trigger debe evitarlo y mostrar un mensaje de error personalizado: 
"No está permitido eliminar reseñas. Contacte al administrador."
*/

CREATE TRIGGER tr_Prevent_Delete

ON Production.ProductReview INSTEAD OF DELETE
AS
BEGIN

    SET NOCOUNT ON

    -- se evalua si el ID de review que se busca eliminar apunta a un registro en la tabla real Production.ProductReview
    -- basicamente, la subconsulta trae todos los IDs, y si alguno de ellos coincide con el select desde deleted, indica
    -- que se busca eliminar un registro y deniega la operacion de eliminacion

    IF EXISTS (

        SELECT 
        
        deleted.ProductReviewID 
        
        FROM deleted 
        
        WHERE deleted.ProductReviewID IN (SELECT PR.ProductReviewID FROM Production.ProductReview AS PR)
        )

            THROW 50001, 'No está permitido eliminar reseñas. Contacte al administrador.', 1
END
GO


/*
Cursor Básico de Reporte:
Crea un script T-SQL que utilice un cursor para recorrer la tabla Production.Product.
Filtro: Solo productos que tengan un SafetyStockLevel mayor a 500.
Acción: Imprimir en la consola (usando PRINT) el siguiente mensaje por cada producto: "Producto: [Nombre] - Stock de Seguridad: [SafetyStockLevel]"
*/

DECLARE cr_ProductionProduct CURSOR

FOR SELECT 
    
    -- se seleccionan los tres campos que se desea mostrar

    PP.ProductID,
    PP.Name,
    PP.SafetyStockLevel
    
    FROM Production.Product AS PP 
    
    WHERE PP.SafetyStockLevel >= 500

DECLARE @id INT, @nombre NVARCHAR(100), @stockSeguro INT -- para guardar los valores del SELECT declaro variables auxiliares


-- se abre el cursor y se trae el 1er resultado con FETCH NEXT
OPEN cr_ProductionProduct

-- las variables se guardan en el mismo orden en el cual las trae el SELECT

FETCH NEXT FROM cr_ProductionProduct INTO @id, @nombre, @stockSeguro

WHILE @@FETCH_STATUS = 0 -- se va a ciclar mientras haya elementos para leer desde el cursor
BEGIN
    
    PRINT CONCAT('ID: ', @id, ' - Producto: ', @nombre, '- Stock de seguridad: ', @stockSeguro)

    FETCH NEXT FROM cr_ProductionProduct INTO @id, @nombre, @stockSeguro -- cada pasada trae el siguiente elemento

END

-- una vez terminado de leer el cursor, se cierra y luego se desaloja de memoria para ahorrar recursos

CLOSE cr_ProductionProduct

DEALLOCATE cr_ProductionProduct


/*
Cursor con Lógica Condicional (Simulación de Proceso):

Se desea analizar las ventas históricas. Crea un cursor que recorra la tabla Sales.SalesOrderHeader.

Datos a obtener: SalesOrderID, OrderDate y TotalDue.

Filtro: Solo procesar las órdenes del año 2011.

Lógica por fila:

Si el TotalDue supera los $20,000, imprimir: "Orden [ID] ([Fecha]): Venta ALTA"
Si es menor o igual a $20,000, imprimir: "Orden [ID] ([Fecha]): Venta ESTANDAR"
*/

DECLARE cr_SalesOrderHeader CURSOR

FOR SELECT 
    
    Sales.SalesOrderHeader.SalesOrderID,
    Sales.SalesOrderHeader.OrderDate,
    Sales.SalesOrderHeader.TotalDue

    FROM Sales.SalesOrderHeader

    WHERE OrderDate BETWEEN DATETIMEFROMPARTS(2011, 1, 1, 0, 0, 0, 0) AND DATETIMEFROMPARTS(2011, 12, 31, 23, 59, 59, 0)

OPEN cr_SalesOrderHeader

DECLARE @saleID INT, @OrderDate DATETIME, @totalDue MONEY


FETCH NEXT FROM cr_SalesOrderHeader INTO @saleID, @OrderDate, @totalDue
WHILE @@FETCH_STATUS = 0
BEGIN

    IF @totalDue > 20000.0
    BEGIN
        PRINT CONCAT('Orden', @saleID, 'Fecha', @OrderDate, 'Venta', 'Alta')
    END
    ELSE
        PRINT CONCAT('Orden', @saleID, 'Fecha', @OrderDate, 'Venta', 'Estandar')

    FETCH NEXT FROM cr_SalesOrderHeader INTO @saleID, @OrderDate, @totalDue
    
END

CLOSE cr_SalesOrderHeader

DEALLOCATE cr_SalesOrderHeader