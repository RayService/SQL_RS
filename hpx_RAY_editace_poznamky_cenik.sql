USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_editace_poznamky_cenik]    Script Date: 26.06.2025 12:33:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_editace_poznamky_cenik]
@Poznamka NTEXT,
@ID INT
AS

UPDATE TabStrukKusovnik_kalk_cenik SET
Poznamka = @Poznamka
WHERE ID = @ID
GO

