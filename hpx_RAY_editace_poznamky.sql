USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_editace_poznamky]    Script Date: 26.06.2025 14:14:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_editace_poznamky]
@Poznamka NTEXT,
@ID INT
AS

UPDATE RAY_Parametry_Definice SET
Poznamka = @Poznamka
WHERE ID = @ID
GO

