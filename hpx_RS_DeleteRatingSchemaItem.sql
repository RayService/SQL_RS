USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_DeleteRatingSchemaItem]    Script Date: 26.06.2025 14:07:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_DeleteRatingSchemaItem]
@ID INT	--id schéma, na kterém stojím
AS
SET NOCOUNT ON;

--mazání záznamů z tabulky Tabx_RAY_EmployeeRating_SchemaItem - schéma hodnocení

DECLARE @IDChange INT;
DECLARE @IDSchema INT;
BEGIN
SET @IDSchema=(SELECT IDSchema FROM Tabx_RAY_EmployeeRating_SchemaItem WHERE ID=@ID)

INSERT INTO Tabx_RAY_EmployeeRating_Change (IDSchema)
VALUES (@IDSchema)
SET @IDChange=(SELECT SCOPE_IDENTITY())

UPDATE Tabx_RAY_EmployeeRating_SchemaItem SET IDChangeTo=@IDChange WHERE ID=@ID

END;
GO

