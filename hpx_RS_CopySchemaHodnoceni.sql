USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_CopySchemaHodnoceni]    Script Date: 26.06.2025 16:14:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_CopySchemaHodnoceni] @SchemaDescription NVARCHAR(255), @kontrola BIT, @ID INT
AS
SET NOCOUNT ON;

--cvičně
--DECLARE @kontrola BIT=1
--DECLARE @ID INT=215
--DECLARE @SchemaDescription NVARCHAR(255)='test'

--ostře
DECLARE @IDSchemaNew INT
DECLARE @Title NVARCHAR(255)
DECLARE @Description NVARCHAR(255)
DECLARE @MaxValue INT
DECLARE @PctOfVariableWage INT
DECLARE @PaymentFrequency INT
DECLARE @IDKPI INT
DECLARE @Ordering INT
DECLARE @MaxPctOfFixWage INT
DECLARE @PctValue INT

IF @kontrola=1
BEGIN
	INSERT INTO Tabx_RAY_EmployeeRating_Schema(Title, Description)
	SELECT sch.Title, @SchemaDescription
	FROM Tabx_RAY_EmployeeRating_Schema sch
	WHERE sch.ID=@ID
	SET @IDSchemaNew=(SELECT SCOPE_IDENTITY())
	--zjistíme položky označeného schématu pro následné kopírování
	IF OBJECT_ID('tempdb..#PolozkySchematu') IS NOT NULL DROP TABLE #PolozkySchematu
	CREATE TABLE #PolozkySchematu(
	ID INT IDENTITY(1,1),
	Title NVARCHAR(255),
	Description NVARCHAR(255),
	MaxValue int NULL,
	PctOfVariableWage int NULL,
	PaymentFrequency int NOT NULL,
	IDKPI int NULL,
	Ordering int NOT NULL,
	IDSchema int NULL,
	IDChangeFrom int NULL,
	IDChangeTo int NULL,
	MaxPctOfFixWage int NULL,
	Disabled bit NOT NULL,
	PctValue int NULL,
	WagePartNr int NULL,
	Workflow nvarchar(20) NULL)
	--nasypeme stávající položky z označeného schématu
	INSERT INTO #PolozkySchematu (Title, Description, MaxValue, PctOfVariableWage, PaymentFrequency, IDKPI, Ordering, IDSchema, IDChangeFrom, IDChangeTo, MaxPctOfFixWage, Disabled, PctValue, WagePartNr, Workflow)
	SELECT schit.Title, schit.Description, schit.MaxValue,schit.PctOfVariableWage,schit.PaymentFrequency,schit.IDKPI,schit.Ordering, @IDSchemaNew, schit.IDChangeFrom,schit.IDChangeTo,schit.MaxPctOfFixWage,0,schit.PctValue,schit.WagePartNr,schit.Workflow
	FROM Tabx_RAY_EmployeeRating_SchemaItem schit
	LEFT OUTER JOIN Tabx_RAY_EmployeeRating_Schema sch ON schit.IDSchema=sch.ID
	WHERE (schit.IDSchema=@ID)AND(schit.IDChangeTo IS NULL)AND(schit.Disabled=0)
	SELECT *
	FROM #PolozkySchematu
	
	--za každý řádek spustíme proceduru pro vložení položky schématu
	DECLARE @IDStart INT, @IDEnd INT
	SELECT @IDStart=MIN(ID), @IDEnd=MAX(ID)
	FROM #PolozkySchematu
	WHILE @IDStart<=@IDEnd
		BEGIN
		SELECT @Title=Title, @MaxValue=MaxValue, @PctOfVariableWage=PctOfVariableWage, @MaxPctOfFixWage=MaxPctOfFixWage, @PaymentFrequency=PaymentFrequency, @IDKPI=IDKPI, @Ordering=Ordering, @PctValue=PctValue
		FROM #PolozkySchematu
		WHERE ID=@IDStart
			EXEC dbo.hpx_RS_InsertRatingSchemaItem @Title, @MaxValue, @PctOfVariableWage, @MaxPctOfFixWage, @PaymentFrequency, @IDKPI, @Ordering, @IDSchema=@IDSchemaNew, @PctValue=@PctValue
			SET @IDStart=@IDStart+1;
		END;
END
ELSE
BEGIN
	RAISERROR('Nic neproběhne, není zatrženo Provést.',16,1)
	RETURN
END;
GO

