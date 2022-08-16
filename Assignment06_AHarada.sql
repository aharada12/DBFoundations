--*************************************************************************--
-- Title: Assignment06
-- Author: AHarada
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-08-10, AHarada, Completed Script
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AHarada')
	 Begin 
	  Alter Database [Assignment06DB_AHarada] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AHarada;
	 End
	Create Database Assignment06DB_AHarada;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_AHarada;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Go

Create View vCategories
With SCHEMABINDING
As
    Select 
    CategoryID,
    CategoryName
    From dbo.Categories
Go

Create View vProducts
With SCHEMABINDING
As
    Select 
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice
    From dbo.Products
Go

Create View vEmployees
With SCHEMABINDING
As
    Select
    EmployeeID,
    EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName,
    ManagerID
    From dbo.Employees
Go

Create View vInventories
With SCHEMABINDING
As
    Select
    InventoryID,
    InventoryDate,
    EmployeeID,
    ProductID,
    Inventories.Count as InventoryCount
    From dbo.Inventories
Go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On Categories to Public
Grant Select On vCategories to Public

Deny Select On Products to Public
Grant Select On vProducts to Public

Deny Select On Employees to Public
Grant Select On vEmployees to Public

Deny Select On Inventories to Public
Grant Select On vInventories to Public

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Look at columns
/*Select * From Categories
Select * From Products

--Look at data we want
Select CategoryName From Categories
Select ProductName, UnitPrice From Products

--Join Tables
Select CategoryName, ProductName, UnitPrice
From Products
Join Categories
On Products.CategoryID = Categories.CategoryID*/

--Create View
Go

Create View vProductsByCategories
As
    Select Top 10000
    CategoryName, ProductName, UnitPrice
    From vProducts
    Join vCategories
        On vProducts.CategoryID = vCategories.CategoryID
    Order By CategoryName, ProductName
Go

Select * From vProductsByCategories

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--Look at all columns
/*Select * From Products
Select * From Inventories

--Look at data we want
Select ProductName From Products
Select InventoryDate, Inventories.Count From Inventories

--Join tables
Select ProductName, InventoryDate, Inventories.Count
From Inventories
Join Products
On Inventories.ProductID = Products.ProductID*/
Go

Create View vInventoriesByProductsByDates
As
    Select Top 10000
    ProductName, InventoryDate, InventoryCount
    From vInventories
    Join vProducts
        On vInventories.ProductID = vProducts.ProductID
    Order By ProductName, InventoryDate, InventoryCount
Go

Select * From vInventoriesByProductsByDates

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Look at columns
/*Select * From Employees
Select * From Inventories

--Combine Employee first and last name
Select EmployeeFirstName + ' ' + EmployeeLastName
From Employees

--Join tables
Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName, InventoryDate
From Employees
Join Inventories
On Employees.EmployeeID = Inventories.EmployeeID*/
Go 

Create View vInventoriesByEmployeesByDates
As
    Select Distinct Top 10000
    InventoryDate, EmployeeName
    From vInventories
    Inner Join vEmployees
    On vInventories.EmployeeID = vEmployees.EmployeeID
    Order By InventoryDate
Go

Select * From vInventoriesByEmployeesByDates

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Look at data
/*Select * From Categories
Select * From Products
Select * From Inventories

--Look at desired columns
Select CategoryName From Categories
Select ProductName From Products
Select InventoryDate, Inventories.Count From Inventories

--Join Tables
Select CategoryName, ProductName, InventoryDate, Inventories.Count
From Inventories
Inner Join Products
On Products.ProductID = Inventories.ProductID
Inner Join Categories
On Categories.CategoryID = Products.CategoryID*/

--Order Table
Go

Create View vInventoriesByProductsByCategories
As
    Select Top 10000 CategoryName, ProductName, InventoryDate, InventoryCount
    From vInventories
    Inner Join vProducts
        On vProducts.ProductID = vInventories.ProductID
    Inner Join vCategories
        On vCategories.CategoryID = vProducts.CategoryID
    Order By 1, 2, 3, 4
Go
Select * From vInventoriesByProductsByCategories

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Look at columns
/*Select * From Categories
Select * From Products
Select * From Inventories
Select * From Employees

--Look at data
Select CategoryName From Categories
Select ProductName From Products
Select InventoryDate, Inventories.Count From Inventories
Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName From Employees

--Join Tables
Select CategoryName, ProductName, InventoryDate, Inventories.Count,
    EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From Employees
Inner Join Inventories
On Inventories.EmployeeID = Employees.EmployeeID
Inner Join Products
On Products.ProductID = Inventories.ProductID
Inner Join Categories
On Categories.CategoryID = Products.CategoryID*/

--Order data
Go

Create View vInventoriesByProductsByEmployees
As
    Select Top 10000 CategoryName, ProductName, InventoryDate, InventoryCount, EmployeeName
    From vEmployees
    Inner Join vInventories
        On vInventories.EmployeeID = vEmployees.EmployeeID
    Inner Join vProducts
        On vProducts.ProductID = vInventories.ProductID
    Inner Join vCategories
        On vCategories.CategoryID = vProducts.CategoryID
    Order By 3,1,2,5
Go
Select * From vInventoriesByProductsByEmployees

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Look at columns
/*Select * From Products
Select * From Categories
Select * From Inventories

--Query Products
Select ProductName, ProductID From Products
Where ProductName In ('Chai', 'Chang')

--Join Tables
Select CategoryName, ProductName, InventoryDate, Inventories.Count,
    EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From Employees
Inner Join Inventories
On Inventories.EmployeeID = Employees.EmployeeID
Inner Join Products
On Products.ProductID = Inventories.ProductID
Inner Join Categories
On Categories.CategoryID = Products.CategoryID

--Subquery desired Product Names
Select CategoryName, ProductName, InventoryDate, Inventories.Count,
    EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From Employees
Inner Join Inventories
On Inventories.EmployeeID = Employees.EmployeeID
Inner Join (Select * From Products Where ProductName In ('Chai', 'Chang')) as P
On P.ProductID = Inventories.ProductID
Inner Join Categories
On Categories.CategoryID = P.CategoryID*/

--Order table

Go

Create View vInventoriesForChaiAndChangByEmployees
As
    Select Top 10000 CategoryName, ProductName, InventoryDate, InventoryCount, EmployeeName
    From vEmployees
    Inner Join vInventories
        On vInventories.EmployeeID = vEmployees.EmployeeID
    Inner Join 
        (Select * From vProducts Where ProductName In ('Chai', 'Chang')) as P
        On P.ProductID = vInventories.ProductID
    Inner Join vCategories
        On vCategories.CategoryID = P.CategoryID
    Order By 3,1,2
Go

Select * From vInventoriesForChaiAndChangByEmployees

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Look at data
/*Select * From Employees

--Select data
Select Mgr.EmployeeLastName, Emp.EmployeeLastName
From Employees as Emp
Inner Join Employees Mgr
On Emp.ManagerID = Mgr.EmployeeID

--Add full names
Select [Manager] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
    [Employee] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
From Employees as Emp
Inner Join Employees Mgr
On Emp.ManagerID = Mgr.EmployeeID*/

--Order Results
Go

Create View vEmployeesByManager
As
    Select Top 10000 [Manager] = Mgr.EmployeeName,
        [Employee] = Emp.EmployeeName
    From vEmployees as Emp
    Inner Join vEmployees Mgr
        On Emp.ManagerID = Mgr.EmployeeID
    Order By Manager, Employee
Go
Select * From vEmployeesByManager

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--List all data from Views
/*
Select * From vCategories
Select * From vProducts
Select * From vInventories
Select * From vEmployees
Select * From vEmployeesByManager

--List all columns
Select CategoryID, CategoryName From vCategories
Select ProductID, ProductName, CategoryID, UnitPrice From vProducts
Select InventoryID, InventoryDate, EmployeeID, ProductID, InventoryCount From vInventories
Select EmployeeID, EmployeeName, ManagerID From vEmployees
Select Manager, Employee From vEmployeesByManager

--Join Table
Select 
C.CategoryID, CategoryName, 
P.ProductID, ProductName, UnitPrice, 
InventoryID, InventoryDate, E.EmployeeID, InventoryCount,
EmployeeName, ManagerID, Manager
From vCategories as C
Inner Join vProducts as P
    On C.CategoryID = P.CategoryID
Inner Join vInventories as I
    On P.ProductID = I.ProductID
Inner Join vEmployees as E
    On I.EmployeeID = E.EmployeeID
Inner Join vEmployeesByManager as M
    On E.EmployeeName = M.Employee

--OrderTable
Select 
C.CategoryID, CategoryName, 
P.ProductID, ProductName, UnitPrice, 
InventoryID, InventoryDate, E.EmployeeID, InventoryCount,
EmployeeName, ManagerID, Manager
From vCategories as C
Inner Join vProducts as P
    On C.CategoryID = P.CategoryID
Inner Join vInventories as I
    On P.ProductID = I.ProductID
Inner Join vEmployees as E
    On I.EmployeeID = E.EmployeeID
Inner Join vEmployeesByManager as M
    On E.EmployeeName = M.Employee
Order By CategoryName, ProductName, InventoryID, EmployeeName 
*/

--Create View
Go

Create View vInventoriesByProductsByCategoriesByEmployees
As
Select Top 10000
C.CategoryID, CategoryName, 
P.ProductID, ProductName, UnitPrice, 
InventoryID, InventoryDate, E.EmployeeID, InventoryCount,
EmployeeName, ManagerID, Manager
From vCategories as C
Inner Join vProducts as P
    On C.CategoryID = P.CategoryID
Inner Join vInventories as I
    On P.ProductID = I.ProductID
Inner Join vEmployees as E
    On I.EmployeeID = E.EmployeeID
Inner Join vEmployeesByManager as M
    On E.EmployeeName = M.Employee
Order By CategoryName, ProductName, InventoryID, EmployeeName
Go

Select * From vInventoriesByProductsByCategoriesByEmployees




-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/