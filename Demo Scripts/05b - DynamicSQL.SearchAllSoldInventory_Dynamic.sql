USE AutoDealershipDemo
GO

CREATE OR ALTER PROCEDURE DynamicSQL.SearchAllSoldInventory_Dynamic (
	@MakeName VARCHAR(50) = NULL, --'Toyota',
	@ModelName VARCHAR(50) = NULL, --'RAV4',
	@ColorName VARCHAR(50) = NULL, --'Black',
	@PackageName VARCHAR(50) = NULL, --'Special Edition',
	@InvoicePriceMin MONEY = NULL, --,
	@InvoicePriceMax MONEY = NULL, --,
	@MSRPMin MONEY = NULL, --,
	@MSRPMax MONEY = NULL, --,
	@SellPriceMin MONEY = NULL, --,
	@SellPriceMax MONEY = NULL, --,
	@DateReceivedMin DATE = NULL, --'2020-01-01',
	@DateReceivedMax DATE = NULL, --'2021-12-01',
	@TransactionDateMin DATETIME = NULL, --'2021-01-01',
	@TransactionDateMax DATETIME = NULL, --'2023-01-01',
	@Debug BIT = 0
)
AS
BEGIN

DECLARE @SQL NVARCHAR(MAX),
	@ParmDefinition NVARCHAR(500);  

/* get the list of parameters */
SELECT @ParmDefinition = ' @MakeName varchar(50), @ModelName varchar(50), @ColorName varchar(50), @PackageName varchar(50), @InvoicePriceMin money, @InvoicePriceMax money, @MSRPMin money, @MSRPMax money, @SellPriceMin money, @SellPriceMax money, @DateReceivedMin date, @DateReceivedMax date, @TransactionDateMin datetime, @TransactionDateMax datetime'

/* create the statement */
SELECT @SQL = N'
SELECT  /* SearchAllSoldInventory_Dynamic */
		I.VIN,
		mk.MakeName,
		ml.ModelName,
		clr.ColorName,
		pkg.PackageName,
		I.InvoicePrice,
		I.MSRP,
		sh.SellPrice,
		I.DateReceived,
		sh.TransactionDate,
		I.InventoryID,
		sh.SalesHistoryID
	FROM dbo.Inventory as I
	INNER JOIN Vehicle.BaseModel as bm
		ON I.BaseModelID = bm.BaseModelID
	INNER JOIN Vehicle.Make as mk
		ON bm.MakeID = mk.MakeID
	INNER JOIN Vehicle.Model as ml
		ON bm.ModelID = ml.ModelID
	INNER JOIN Vehicle.Color as clr
		ON bm.ColorID = clr.ColorID
	INNER JOIN Vehicle.Package as pkg
		ON I.PackageID = pkg.PackageID    
	INNER JOIN dbo.SalesHistory as sh
		ON sh.InventoryID = I.InventoryID
	WHERE 
		/* Create a constant to make it easier to add things later on. */
		1 = 1 '
	+ CASE WHEN NULLIF(@MakeName, '') IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND mk.MakeName = @MakeName'
	END 
	+ CASE WHEN NULLIF(@ModelName, '') IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND ml.ModelName = @ModelName'
	END
	+ CASE WHEN NULLIF(@ColorName, '') IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND clr.ColorName = @ColorName'
	END
	+ CASE WHEN NULLIF(@PackageName, '') IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND pkg.PackageName = @PackageName'
	END
	+ CASE WHEN NULLIF(@InvoicePriceMin, 0) IS NULL AND @InvoicePriceMax IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND (
		I.InvoicePrice BETWEEN COALESCE(@InvoicePriceMin, 1) AND COALESCE(@InvoicePriceMax, 999999)
	)'
		END
	+ CASE WHEN NULLIF(@MSRPMin, 0) IS NULL AND @MSRPMax IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND (
		I.MSRP BETWEEN COALESCE(@MSRPMin, 1) AND COALESCE(@MSRPMax, 999999)
	)'
		END
	+ CASE WHEN NULLIF(@SellPriceMin, 0) IS NULL AND @SellPriceMax IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND (
		sh.SellPrice BETWEEN COALESCE(@SellPriceMin, 1) AND COALESCE(@SellPriceMax, 999999)
	)'
		END
	+ CASE WHEN NULLIF(@DateReceivedMin, '1900-01-01') IS NULL AND NULLIF(@DateReceivedMax, '2050-01-01') IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND (
		I.DateReceived BETWEEN COALESCE(@DateReceivedMin, ''1900-01-01'') AND COALESCE(@DateReceivedMax, ''2050-01-01'')
	)'
		END
	+ CASE WHEN NULLIF(@TransactionDateMin, '1900-01-01') IS NULL AND NULLIF(@TransactionDateMax, '2050-01-01') IS NULL THEN ''
		ELSE CHAR(10) + CHAR(13) + 'AND (
		sh.TransactionDate BETWEEN COALESCE(@TransactionDateMin, ''1900-01-01'') AND COALESCE(@TransactionDateMax, ''2050-01-01'')
	)'
		END

/* If debugging, print the statement */
IF @debug = 1
BEGIN
	PRINT 'Parameter list: ' + @ParmDefinition

	PRINT 'Generated SQL Statement: 
	--------------------------
' + @SQL

END

/* Execute the statement */
EXEC sp_executesql @SQL, @ParmDefinition, @MakeName, @ModelName, @ColorName, @PackageName, @InvoicePriceMin, @InvoicePriceMax, @MSRPMin, @MSRPMax, @SellPriceMin, @SellPriceMax , @DateReceivedMin , @DateReceivedMax , @TransactionDateMin , @TransactionDateMax 

END
GO
