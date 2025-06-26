USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_InsertRatingSchemaItem]    Script Date: 26.06.2025 14:06:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_InsertRatingSchemaItem]
@Title NVARCHAR(255),
@MaxValue INT,
@PctOfVariableWage INT,
@MaxPctOfFixWage INT,
@PaymentFrequency INT,
@IDKPI INT,
@Ordering INT,
@IDSchema INT,
@PctValue INT
--@ID INT	--id schéma, na kterém stojím
AS
SET NOCOUNT ON;

--Vkládání záznamů do tabulky Tabx_RAY_EmployeeRating_SchemaItem - schéma hodnocení
--vkládání ze seznamu položek schemat
--můžu si zjistit IDSchema, z nějž jsem akci spouštěl a doplnit si tak IDSchema
/*
DECLARE @IDHlavicka INT
SELECT TOP 1 @IDHlavicka = CAST(Cislo as INT) FROM #TabExtKomPar WHERE Popis='STVlastID'
*/
DECLARE @IDRoot INT;
DECLARE @IDChangeFrom INT;

BEGIN
INSERT INTO Tabx_RAY_EmployeeRating_SchemaItem (Title,MaxValue,PctOfVariableWage,MaxPctOfFixWage,PaymentFrequency,IDKPI,Ordering,IDSchema,PctValue)
VALUES (@Title, @MaxValue, @PctOfVariableWage, @MaxPctOfFixWage, @PaymentFrequency, @IDKPI, @Ordering, @IDSchema, @PctValue)

SET @IDRoot=(SELECT SCOPE_IDENTITY())
UPDATE Tabx_RAY_EmployeeRating_SchemaItem SET IDRoot=@IDRoot WHERE ID=@IDRoot

--pro jistotu vyNULLování dvou atributů:
UPDATE dbo.Tabx_RAY_EmployeeRating_SchemaItem SET MaxValue = NULL, MaxPctOfFixWage = NULL WHERE PctOfVariableWage IS NOT NULL AND ID=@IDRoot

INSERT INTO Tabx_RAY_EmployeeRating_Change (IDSchema)
VALUES (@IDSchema)
SET @IDChangeFrom=(SELECT SCOPE_IDENTITY())

UPDATE Tabx_RAY_EmployeeRating_SchemaItem SET IDChangeFrom=@IDChangeFrom WHERE ID=@IDRoot

END;
GO

