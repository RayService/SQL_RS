USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UpdateRatingSchemaItem]    Script Date: 26.06.2025 14:07:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_UpdateRatingSchemaItem]
@Title NVARCHAR(255),
@MaxValue INT,
@PctOfVariableWage INT,
@MaxPctOfFixWage INT,
@PaymentFrequency INT,
@IDKPI INT,
@Ordering INT,
@IDSchema INT,
@PctValue INT,
@ID INT	--id schéma, na kterém stojím
AS
SET NOCOUNT ON;

--Vkládání záznamů do tabulky Tabx_RAY_EmployeeRating_SchemaItem - schéma hodnocení
--vkládání ze seznamu Schemat
DECLARE @IDRoot INT;
DECLARE @IDChange INT;
--zjištění původních hodnot před změnou
DECLARE
@TitleOld NVARCHAR(255),
@MaxValueOld INT,
@PctOfVariableWageOld INT,
@MaxPctOfFixWageOld INT,
@PaymentFrequencyOld INT,
@IDKPIOld INT,
@OrderingOld INT,
@IDSchemaOld INT,
@PctValueOld INT,
@IDRootOld INT

SELECT @TitleOld=Title, @MaxValueOld=MaxValue, @PctOfVariableWageOld=PctOfVariableWage, @MaxPctOfFixWageOld=ISNULL(MaxPctOfFixWage,0), @PaymentFrequencyOld=PaymentFrequency, @IDKPIOld=ISNULL(IDKPI,0), @OrderingOld=Ordering, @IDSchemaOld=IDSchema,@PctValueOld=ISNULL(PctValue,0),@IDRootOld=IDRoot
FROM Tabx_RAY_EmployeeRating_SchemaItem
WHERE ID=@ID

IF (@TitleOld<>@Title OR @MaxValueOld<>@MaxValue OR @PctOfVariableWageOld<>@PctOfVariableWage OR @MaxPctOfFixWageOld<>@MaxPctOfFixWage OR @PaymentFrequencyOld<>@PaymentFrequency OR @IDKPIOld<>@IDKPI OR @OrderingOld<>@Ordering OR @IDSchemaOld<>@IDSchema OR ISNULL(@PctValueOld,0)<>ISNULL(@PctValue,0))
BEGIN
INSERT INTO Tabx_RAY_EmployeeRating_SchemaItem (Title,MaxValue,PctOfVariableWage,MaxPctOfFixWage,PaymentFrequency,IDKPI,Ordering,IDSchema,PctValue,DatZmeny,Zmenil)
VALUES (@Title, @MaxValue, @PctOfVariableWage, @MaxPctOfFixWage, @PaymentFrequency, @IDKPI, @Ordering, @IDSchema, @PctValue, GETDATE(), SUSER_SNAME())

SET @IDRoot=(SELECT SCOPE_IDENTITY())
UPDATE Tabx_RAY_EmployeeRating_SchemaItem SET IDRoot=@IDRootOld WHERE ID=@IDRoot

--pro jistotu vyNULLování dvou atributů:
--UPDATE dbo.Tabx_RAY_EmployeeRating_SchemaItem SET MaxValue = NULL, PctValue=NULL, PctOfVariableWage = NULL WHERE PctOfVariableWage IS NOT NULL AND ID=@ID
UPDATE dbo.Tabx_RAY_EmployeeRating_SchemaItem SET MaxValue = NULL, MaxPctOfFixWage = NULL WHERE PctOfVariableWage IS NOT NULL AND ID=@IDRoot

INSERT INTO Tabx_RAY_EmployeeRating_Change (IDSchema)
VALUES (@IDSchema)
SET @IDChange=(SELECT SCOPE_IDENTITY())

UPDATE Tabx_RAY_EmployeeRating_SchemaItem SET IDChangeTo=@IDChange WHERE ID=@ID
UPDATE Tabx_RAY_EmployeeRating_SchemaItem SET IDChangeFROM=@IDChange WHERE ID=@IDRoot

END;

--MaxValue musí být vždy NULL OR PctOfVariableWage OR MaxPctOfFixWage
--MaxValue = NULL všude kromě MFV
--PctOfVariableWage, kde je 0 a MaxValue = NULL - opravit
GO

