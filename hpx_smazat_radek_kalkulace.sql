USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_smazat_radek_kalkulace]    Script Date: 26.06.2025 13:36:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_smazat_radek_kalkulace] @ID INT
AS
BEGIN
DELETE FROM TabStrukKusovnik_kalk_cenik WHERE ID = @ID
END
GO

