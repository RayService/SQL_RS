USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ASOL_HodnoceniZakazek_Konec]    Script Date: 26.06.2025 13:55:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_ASOL_HodnoceniZakazek_Konec]
AS
BEGIN -- begin procedure
SET NOCOUNT ON
DELETE dbo.Tabx_ASOL_HodnoceniZakazek WHERE Autor=(SELECT @@spid)		-- zruš záznamy uživatele
END -- end procedure
GO

