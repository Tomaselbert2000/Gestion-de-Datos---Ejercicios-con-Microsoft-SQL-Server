USE AdventureWorks2014;

/*
1- p_InsCulture(id,newName,date): Este sp debe permitir dar de alta un nuevo 
registro en la tabla Production.Culture. Los tipos de datos de los parámetros 
deben corresponderse con la tabla. Para ayudarse, se podrá ejecutar el 
procedimiento sp_help“<esquema.objeto>”.
*/

EXEC sp_help 'Production.Culture' -- se ejecuta el SP a fin de obtener información
GO

CREATE PROCEDURE p_InsCulture(@id NCHAR(6), @newName NVARCHAR(50), @date DATETIME)
AS
BEGIN

    SET NOCOUNT ON

    -- dado que se trata de una operacion de insercion que puede o no fallar,
    -- se engloba dentro de un bloque Try & Catch

    BEGIN TRY
        
        -- se realiza la transaccion de insercion, y luego se commitea
        BEGIN TRANSACTION

            INSERT INTO Production.Culture(CultureID, Name, ModifiedDate)
            VALUES(@id, @newName, @date)

        COMMIT TRANSACTION

    END TRY

    -- en caso de fallar el bloque anterior, el control pasa al CATCH
    BEGIN CATCH
        -- se revierten los cambios y se lanza la excepcion
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW

    END CATCH
END
GO


/*
2- p_SelCuture(id): Este sp devolverá el registro completo según el id enviado.
*/

CREATE PROCEDURE p_SelCuture(@id NCHAR(6))
AS
BEGIN

    SET NOCOUNT ON

    SELECT
    
    PC.CultureID AS 'ID de Cultura',
    PC.Name AS 'Nombre',
    PC.ModifiedDate AS 'Fecha de modificacion'

    FROM Production.Culture AS PC

    WHERE PC.CultureID = @id
END
GO


/*
3- p_DelCulture(id): Este sp debe borrar el id enviado por parámetro de la tabla Production.Culture.
*/

CREATE PROCEDURE p_DelCulture(@id NCHAR(6))
AS
BEGIN

    SET NOCOUNT ON

    BEGIN TRY

        BEGIN TRANSACTION

            DELETE FROM Production.Culture
            WHERE CultureID = @id

        COMMIT TRANSACTION
    
    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW

    END CATCH
END
GO


/*
4- p_UpdCulture(id): Dado un id debe permitirme cambiar el campo newName del registro.
*/

CREATE PROCEDURE p_UpdCulture(@id NCHAR(6), @newName NVARCHAR(50))
AS
BEGIN

    SET NOCOUNT ON

    BEGIN TRY

        BEGIN TRANSACTION

            UPDATE Production.Culture
            
            SET Name = @newName

            WHERE CultureID = @id

        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW

    END CATCH
END
GO


/*
5- sp_CantCulture (cant out): Realizar un sp que devuelva la cantidad de 
registros en Culture. El resultado deberá colocarlo en una variable de salida.
*/

CREATE PROCEDURE sp_CantCulture(@cant INT OUTPUT)
AS
BEGIN

    SET NOCOUNT ON

    SELECT @cant = COUNT(PC.CultureID) 
    
    FROM Production.Culture AS PC

    RETURN @cant

END
GO

/*
6- sp_CultureAsignadas : Realizar un sp que devuelva solamente las 
Culture’s que estén siendo utilizadas en las tablas (Verificar qué tabla/s la 
están referenciando). Sólo debemos devolver id y nombre de la Cultura.
*/

CREATE PROCEDURE sp_CultureAsignadas
AS
BEGIN

    SET NOCOUNT ON
    
    SELECT

    PC.CultureID AS 'ID Cultura',
    PC.Name AS 'Nombre'

    FROM Production.Culture AS PC

    WHERE EXISTS (
        SELECT 
        
        PMPDC.CultureID
        
        FROM Production.ProductModelProductDescriptionCulture AS PMPDC
        )
END
GO


/*
7- p_ValCulture(id,newName,date,operación, valida out): Este sp permitirá 
validar los datos enviados por parámetro. En el caso que el registro sea 
válido devolverá un 1 en el parámetro de salida valida ó 0 en caso contrario. 
El parámetro operación puede ser “U” (Update), “I” (Insert) ó “D” (Delete). 
Lo que se debe validar es:
- Si se está insertando no se podrá agregar un registro con un id 
existente, ya que arrojará un error.
- Tampoco se puede agregar dos registros Cultura con el mismo Name, 
ya que el campo Name es un unique index.
- Ninguno de los campos debería estar vacío.
- La fecha ingresada no puede ser menor a la fecha actual.
*/

CREATE PROCEDURE p_ValCulture(@id NCHAR(6), @newName NVARCHAR(50), @date DATETIME, @operacion CHAR(1), @valida INT OUTPUT)
AS
BEGIN

    SET NOCOUNT ON

    -- validacion de tipo de operacion
    IF @operacion NOT IN ('U', 'I', 'D') OR @operacion IS NULL

        SET @valida = 0
        RETURN
    
    -- validacion de fecha igual o mayor a la fecha actual
    IF @operacion IN ('I', 'U')
    BEGIN

        IF @date < GETDATE()
            SET @valida = 0
            RETURN

    END

    -- validacion de id y newName no nulos
    IF @operacion IN ('I', 'U')
    BEGIN

        IF @id IS NULL OR @newName IS NULL
        SET @valida = 0
        RETURN

    END

    -- validacion de id y newName que no esten en blanco
    IF @operacion IN ('I', 'U')
    BEGIN

        IF @id = '' OR @newName = ''
        SET @valida = 0
        RETURN

    END

    -- dentro de las distintas operaciones, se establece que por defecto el valor sea 0 hasta que se demuestre lo contrario

    IF @operacion = 'I'
    BEGIN
        
        SET @valida = 0

        IF NOT EXISTS (SELECT PC.CultureID FROM Production.Culture AS PC WHERE PC.CultureID = @id)

            SET @valida = 1
            RETURN
    END

    IF @operacion = 'U'
    BEGIN
        SET @valida = 0

        IF NOT EXISTS (SELECT PC.Name FROM Production.Culture AS PC WHERE PC.Name = @newName)

            SET @valida = 1
            RETURN
    END

    IF @operacion = 'D'
    BEGIN
        SET @valida = 0

        IF EXISTS (SELECT PC.CultureID FROM Production.Culture AS PC WHERE PC.CultureID = @id)

            SET @valida = 1
            RETURN
    END

END
GO

/*
8- p_SelCulture2(id out, newName out, date out): A diferencia del sp del punto 
2, este debe emitir todos los datos en sus parámetros de salida. ¿Cómo se 
debe realizar la llamada del sp para testear este sp?
*/

CREATE PROCEDURE p_SelCulture2(@id NCHAR(6), @newName NVARCHAR(50) OUTPUT, @date DATETIME OUTPUT)
AS
BEGIN
    
    SET NOCOUNT ON

    -- dado que los campos deben mostrarse como parámetros de salida, se los asigna de manera directa con un SELECT

    SELECT @newName = PC.Name , @date = PC.ModifiedDate
    
    FROM Production.Culture AS PC WHERE PC.CultureID = @id

END
GO

-- llamado de ejecucion del SP creado: EXEC p_SelCulture2 1, NULL, NULL --> se llenan los campos con NULL


/*
9- Realizar una modificación al sp p_InsCulture para que valide los registros 
ingresados. Por lo cual, deberá invocar al sp p_ValCulture.
Sólo se insertará si la validación es correcta.
*/

ALTER PROCEDURE p_InsCulture(@id NCHAR(6), @newName NVARCHAR(50), @date DATETIME)
AS
BEGIN

    SET NOCOUNT ON

    DECLARE @insertar INT -- se declara una variable que funcione como bandera

    -- y llamando al SP de validacion se le asigna un valor, si es 1 se procede con la transaccion
    EXEC p_ValCulture @id, @newName, @date, 'I', @insertar OUTPUT -- la palabra reservada OUTPUT indica que el valor de salida del SP sea tomado por la variable

    IF @insertar = 1
    BEGIN

        BEGIN TRY

            BEGIN TRANSACTION

                INSERT INTO Production.Culture(CultureID, Name, ModifiedDate)
                VALUES(@id, @newName, @date)

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
10-Idem con el sp p_UpdCulture. Validar los datos a actualizar.
*/

ALTER PROCEDURE p_UpdCulture(@id NCHAR(6), @newName NVARCHAR(50), @date DATETIME)
AS
BEGIN

    SET NOCOUNT ON

    DECLARE @actualizar INT

    -- al igual que el SP anterior, OUTPUT indica que la variable toma el valor de salida del SP de validacion
    EXEC p_ValCulture @id, @newName, @date, 'U', @actualizar OUTPUT

    IF @actualizar = 1

    BEGIN

        BEGIN TRY

            BEGIN TRANSACTION

                UPDATE Production.Culture
                
                SET Name = @newName, ModifiedDate = @date

                WHERE Production.Culture.CultureID = @id

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
11-En p_DelCulture se deberá modificar para que valide que no posea registros relacionados en la tabla que lo referencia.
Investigar cuál es la tabla referenciada e incluir esta validación. 
Si se está utilizando, emitir un mensaje que no se podrá eliminar.
*/

-- al ejecutar el sp de ayuda, se obtiene como resultado que la tabla referenciada es ProductModelProductDescriptionCulture
EXEC sp_help 'Production.Culture'
GO

ALTER PROCEDURE p_DelCulture(@id NCHAR(6))
AS
BEGIN

    SET NOCOUNT ON

    IF NOT EXISTS (SELECT PMPDC.CultureID FROM Production.ProductModelProductDescriptionCulture AS PMPDC WHERE PMPDC.CultureID = @id)

    BEGIN

        BEGIN TRY

            BEGIN TRANSACTION

                DELETE FROM Production.Culture

                WHERE Production.Culture.CultureID = @id

            COMMIT TRANSACTION

        END TRY

        BEGIN CATCH

            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            THROW

        END CATCH
    END
    ELSE
        THROW 50001, 'No es posible eliminar debido a que existen tablas referenciando al registro', 1
END
GO


/*
12-p_CrearCultureHis: Realizar un sp que permita crear la siguiente tabla 
histórica de Cultura. Si existe deberá eliminarse. Ejecutar el procedimiento 
para que se pueda crear:
CREATE TABLE Production.CultureHis( 
CultureID nchar(6) NOT NULL,
Name [dbo].[Name] NOT NULL,
ModifiedDate datetime NOT NULL CONSTRAINT
DF_CultureHis_ModifiedDate DEFAULT (getdate()), 
CONSTRAINT PK_CultureHis_IDDate PRIMARY KEY CLUSTERED (CultureID,
ModifiedDate)
)
- ¿Qué tipo de datos posee asignado el campo Name?
- ¿Qué sucede si no se inserta el campo ModifiedDate?
*/

CREATE PROCEDURE p_CrearCultureHis
AS
BEGIN

    SET NOCOUNT ON

    IF EXISTS (SELECT INFORMATION_SCHEMA.TABLES.TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Production.CultureHis')

    BEGIN

        BEGIN TRY

            BEGIN TRANSACTION
                
                DROP TABLE Production.CultureHis

            COMMIT TRANSACTION

        END TRY

        BEGIN CATCH

            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            THROW

        END CATCH
    END

    CREATE TABLE Production.CultureHis(

        CultureID nchar(6) NOT NULL,
        Name [dbo].[Name] NOT NULL,
        ModifiedDate datetime NOT NULL CONSTRAINT
        DF_CultureHis_ModifiedDate DEFAULT (getdate()), 
        CONSTRAINT PK_CultureHis_IDDate PRIMARY KEY CLUSTERED (CultureID, ModifiedDate)
    )

END
GO

-- El campo Name posee el tipo de dato NVARCHAR con longitud 50

-- En caso que no se inserte el campo ModifiedDate, se inserta
-- por default la fecha actual


/*
13-Dada la tabla histórica creada en el punto 12, se desea modificar el 
procedimiento p_UpdCulture creado en el punto 4. La modificación consiste 
en que cada vez que se cambia algún valor de la tabla Culture se desea 
enviar el registro anterior a una tabla histórica. De esta forma, en la tabla 
Culture siempre tendremos el último registro y en la tabla CutureHis cada 
una de las modificaciones realizadas.
*/

ALTER PROCEDURE p_UpdCulture(@id NCHAR(6), @newName NVARCHAR(50))
AS
BEGIN

    SET NOCOUNT ON

    BEGIN TRY

        BEGIN TRANSACTION
            
            -- a fin de optimizar el codigo, al hacer el INSERT; el SELECT ya traslada los datos de manera más eficiente entre tablas

            INSERT INTO Production.CultureHis
            
            SELECT PC.CultureID, PC.Name FROM Production.Culture AS PC WHERE PC.CultureID = @id

            -- una vez insertado el registro historico se actualizan los nuevos datos en la tabla original

            UPDATE Production.Culture
            
            SET Name = @newName

            WHERE CultureID = @id

        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW

    END CATCH

END
GO


/*
14-p_UserTables(opcional esquema): Realizar un procedimiento que liste 
las tablas que hayan sido creadas dentro de la base de datos con su 
nombre, esquema y fecha de creación. En el caso que se ingrese por 
parámetro el esquema, entonces mostrar únicamente dichas tablas, de lo 
contrario, mostrar todos los esquemas de la base.
*/

CREATE PROCEDURE p_UserTables(@esquema NVARCHAR(50) = NULL)
AS
BEGIN

    SET NOCOUNT ON

    SELECT
    
    ST.name AS 'Tabla',
    ST.create_date AS 'Fecha de creacion',
    SS.name AS 'Esquema'
    
    FROM sys.tables AS ST

    JOIN sys.schemas AS SS ON ST.schema_id = SS.schema_id

    -- acá busco en base al valor que haya quedado en la variable @esquema
    -- si contiene un nombre, se buscará en el WHERE usando ese nombre como
    -- filtro de busqueda.
    -- En caso que sea NULL, traera todos los registros tal como lo pide la consigna

    WHERE SS.name = @esquema OR @esquema IS NULL

END
GO


/*
16-p_UltimoProducto(param): Realizar un procedimiento que devuelva en sus parámetros (output), el último producto ingresado.
*/

EXEC sp_help 'Production.Product' -- al ejecutar este SP, se obtiene que el tipo de dato de la PK de Productos es INT, se usa como base
GO

CREATE PROCEDURE p_UltimoProducto(@idUltimoProductoIngresado INT OUTPUT)
AS
BEGIN
    
    SET NOCOUNT ON

    SELECT TOP 1 -- con TOP 1 se limita al primer resultado de la consulta
    
    @idUltimoProductoIngresado = P.ProductID

    FROM Production.Product AS P

    ORDER BY P.ModifiedDate DESC -- y dado que se ordena por fecha, la más actual queda primera de todo, que junto con el filtro de TOP 1 muestra el producto buscado

END
GO


/*
17-p_TotalVentas(fecha): Realizar un procedimiento que devuelva el total 
facturado en un día dado. El procedimiento, simplemente debe devolver el 
total monetario de lo facturado (Sales).
*/

CREATE PROCEDURE p_TotalVentas(@fecha DATETIME)
AS
BEGIN

    -- a fin de hacer la comparación y el calculo lo más precisos posible, se toma en cuenta el rango total de la fecha ingresada
    -- y se declaran variables auxiliares para calcular

    SET NOCOUNT ON

    DECLARE @rangoInferior DATETIME, @rangoSuperior DATETIME -- ambas variables deben ser DATETIME para poder tomar en cuenta minutos y segundos

    -- a partir de la fecha ingresada como parametro, se asigna a cada variable uno de los extremos del rango
    -- tanto la fecha ingresada a las 00.00 HS y luego la misma fecha a las 23:59:59 que sería el rango maximo

    SET @rangoInferior = DATETIMEFROMPARTS(DATEPART(YEAR, @fecha), DATEPART(MONTH, @fecha), DATEPART(DAY, @fecha), 0, 0, 0, 0)
    SET @rangoSuperior = DATETIMEFROMPARTS(DATEPART(YEAR, @fecha), DATEPART(MONTH, @fecha), DATEPART(DAY, @fecha), 23, 59, 59, 0)

    SELECT
    
    SUM(SSOH.SubTotal) AS 'Total facturado' 
    
    FROM Sales.SalesOrderHeader AS SSOH 
    
    -- por ultimo, dentro del WHERE se filtra aquellas ventas incluidas en el rango dado
    WHERE SSOH.DueDate BETWEEN @rangoInferior AND @rangoSuperior

END