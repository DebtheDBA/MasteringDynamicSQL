/* Compare dynamic vs catch all versions

Make sure to hit Ctrl + M first
*/
USE AutoDealershipDemo
GO 

SET STATISTICS IO ON

-- Execute w. explicit values
EXEC DynamicSQL.SearchAllSoldInventory
	@MakeName = 'Toyota',
	@ModelName = 'RAV4',
	@ColorName = 'Black',
	@PackageName = 'Special Edition',
	@InvoicePriceMin = 20000,
	@InvoicePriceMax = 50000,
	@MSRPMin = 20000,
	@MSRPMax = 55000,
	@SellPriceMin = 20000,
	@SellPriceMax = 60000,
	@DateReceivedMin = '2020-01-01',
	@DateReceivedMax = '2021-12-01',
	@TransactionDateMin = '2021-01-01',
	@TransactionDateMax = '2023-01-01';
GO

-- Execute w. explicit defaults
EXEC DynamicSQL.SearchAllSoldInventory_Dynamic
	@MakeName = 'Toyota',
	@ModelName = 'RAV4',
	@ColorName = 'Black',
	@PackageName = 'Special Edition',
	@InvoicePriceMin = 20000,
	@InvoicePriceMax = 50000,
	@MSRPMin = 20000,
	@MSRPMax = 55000,
	@SellPriceMin = 20000,
	@SellPriceMax = 60000,
	@DateReceivedMin = '2020-01-01',
	@DateReceivedMax = '2021-12-01',
	@TransactionDateMin = '2021-01-01',
	@TransactionDateMax = '2023-01-01';
GO

-- Execute for everything
EXEC DynamicSQL.SearchAllSoldInventory
GO

EXEC DynamicSQL.SearchAllSoldInventory_Dynamic
	@Debug = 1;
GO

-- Just look for one value
EXEC DynamicSQL.SearchAllSoldInventory
	@ColorName = 'Black';
GO

EXEC DynamicSQL.SearchAllSoldInventory_Dynamic
	@ColorName = 'Black',
	@Debug = 1;
GO


-- Just look for a few value
EXEC DynamicSQL.SearchAllSoldInventory
	@ColorName = 'Blizzard',
	@ModelName = 'RAV4';
GO

EXEC DynamicSQL.SearchAllSoldInventory_Dynamic
	@ColorName = 'Blizzard',
	@ModelName = 'RAV4',
	@Debug = 1;
GO
