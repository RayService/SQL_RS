USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_editace_vyhodnoceni]    Script Date: 26.06.2025 9:59:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_editace_vyhodnoceni]
@Vyhodnoceni TINYINT,
@ID INT
AS

UPDATE RAY_Parametry_Definice SET
Vyhodnoceni = @Vyhodnoceni
WHERE ID = @ID
GO

