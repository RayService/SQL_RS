USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_editace_majitele]    Script Date: 26.06.2025 10:00:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_editace_majitele]
@Majitel nvarchar(128),
@ID INT
AS

UPDATE RAY_Parametry_Definice SET
Majitel = @Majitel
WHERE ID = @ID
GO

