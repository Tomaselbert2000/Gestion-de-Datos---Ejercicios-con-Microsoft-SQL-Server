USE AdventureWorks2014

CREATE TABLE Production.RestockAlert (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    LocationID INT,
    CurrentQuantity INT,
    SafetyStockLevel INT,
    AlertDate DATETIME DEFAULT GETDATE()
)
GO

/*
1. tr_Prevent_SalaryDrop (Validación de Datos): 

En Recursos Humanos, está estrictamente prohibido reducir el sueldo histórico de un empleado por error.

Tabla: HumanResources.EmployeePayHistory.

Evento: Trigger AFTER UPDATE.

Lógica: Si se intenta modificar el campo Rate (tarifa de pago), el trigger debe verificar que el nuevo valor no sea menor que el valor anterior.

Acción: Si el nuevo sueldo es menor, debe cancelar la transacción y lanzar un error (usando THROW): "Error: No se permite reducir la tarifa de pago histórica."

Pista: Recuerda unir INSERTED y DELETED por la Clave Primaria compuesta (BusinessEntityID y RateChangeDate).
*/

CREATE TRIGGER tr_Prevent_SalaryDrop

ON HumanResources.EmployeePayHistory AFTER UPDATE
AS
BEGIN

    SET NOCOUNT ON

    IF UPDATE(Rate)
    BEGIN

        IF EXISTS (
            SELECT
            
            D.Rate FROM deleted AS D

            JOIN inserted as I ON D.BusinessEntityID = I.BusinessEntityID AND D.RateChangeDate = I.RateChangeDate

            WHERE I.Rate < D.Rate
        )
            THROW 50001, 'Error: No se permite reducir la tarifa de pago histórica.', 1
    END
END
GO


/*
tr_Inventory_Alert (Monitor de Stock):

Queremos automatizar las alertas de reposición.

Tabla: Production.ProductInventory.

Evento: Trigger AFTER UPDATE.

Condición: Se dispara cuando cambia la columna Quantity.

Lógica: Debes verificar si la nueva cantidad (Quantity) en el inventario es menor que el nivel de stock de seguridad (SafetyStockLevel) del producto.

Reto: La columna SafetyStockLevel no está en ProductInventory, está en la tabla Production.Product. Tendrás que hacer un JOIN adicional dentro del trigger para obtener ese dato.

Acción: Si la cantidad es menor al stock de seguridad, insertar un registro en la tabla Production.RestockAlert con los datos correspondientes.
*/

CREATE TRIGGER tr_Inventory_Alert

ON Production.ProductInventory AFTER UPDATE
AS
BEGIN
    
    SET NOCOUNT ON

    IF UPDATE(Quantity)
    BEGIN

        IF EXISTS (
            
            SELECT

            I.Quantity
            
            FROM inserted AS I

            JOIN Production.Product AS P ON I.ProductID = P.ProductID

            WHERE I.Quantity < P.SafetyStockLevel
        )
        BEGIN

            BEGIN TRY
                
                BEGIN TRANSACTION

                    INSERT INTO Production.RestockAlert(ProductID, LocationID, CurrentQuantity, SafetyStockLevel)

                    SELECT

                    P.ProductID,
                    I.LocationID,
                    I.Quantity,
                    P.SafetyStockLevel

                    FROM Production.Product AS P

                    JOIN inserted AS I ON P.ProductID = I.ProductID
                    
                    WHERE I.Quantity < P.SafetyStockLevel
                    
                COMMIT TRANSACTION

            END TRY

            BEGIN CATCH

                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
                THROW

            END CATCH
        END
    END
END
GO


/*
Cursor de Bonificaciones de Ventas:

La gerencia quiere simular un cálculo de bonos anuales para los vendedores (Sales.SalesPerson) basado en sus ventas del año (SalesYTD).

Consulta Base: Obtener BusinessEntityID, SalesYTD y Bonus actual de la tabla Sales.SalesPerson.

Lógica del Cursor: Recorrer vendedor por vendedor y calcular una "Bonificación Sugerida":

Si SalesYTD es mayor a $2,000,000, la bonificación sugerida es el 5% de las ventas.

Si es menor o igual, la bonificación es el 2%.

Acción: Imprimir en pantalla (PRINT) un texto con el siguiente formato para cada vendedor: "Vendedor [ID]: Ventas $[Monto] - Bono Actual: $[Bono] - Bono Sugerido: $[Calculado]"
*/

DECLARE cr_SalesSalesPerson CURSOR

FOR SELECT

    SSP.BusinessEntityID,
    SSP.SalesYTD,
    SSP.Bonus

    FROM Sales.SalesPerson AS SSP

DECLARE @id INT, @saleYtd MONEY, @bonusActual MONEY, @bonusSugerido MONEY

OPEN cr_SalesSalesPerson

FETCH NEXT FROM cr_SalesSalesPerson INTO @id, @saleYtd, @bonusActual

WHILE @@FETCH_STATUS = 0
BEGIN

    IF @saleYtd > 2000000
    BEGIN

        SET @bonusSugerido = @saleYtd * 0.05

        PRINT CONCAT('Vendedor ', @id, ' Ventas $ ', @saleYtd, 'Bono actual ', @bonusActual, ' Bono sugerido ', @bonusSugerido)

    END
    ELSE

        SET @bonusSugerido = @saleYtd * 0.02

        PRINT CONCAT('Vendedor ', @id, ' Ventas $ ', @saleYtd, 'Bono actual ', @bonusActual, ' Bono sugerido ', @bonusSugerido)

    FETCH NEXT FROM cr_SalesSalesPerson INTO @id, @saleYtd, @bonusActual
END

CLOSE cr_SalesSalesPerson

DEALLOCATE cr_SalesSalesPerson

GO

