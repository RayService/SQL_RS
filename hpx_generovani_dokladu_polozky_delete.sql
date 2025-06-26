USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_generovani_dokladu_polozky_delete]    Script Date: 26.06.2025 11:52:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--zrušení přípravy generování poptávek
CREATE PROCEDURE [dbo].[hpx_generovani_dokladu_polozky_delete]
@ID INT
AS
SET NOCOUNT ON;
-- ==========================================================================================================
-- Author:		MŽ
-- Description:	Zrušení generování poptávek (nabídek) z označených položek ceníku
-- Date: 11.9.2020
-- ==========================================================================================================

BEGIN
DELETE FROM TempGenPol WHERE IDKusovnik = @ID AND Autor = SUSER_SNAME();
UPDATE TabStrukKusovnik_kalk_cenik SET generovany_polozky = NULL, OrgNabidka = NULL, OrgNabidka2 = NULL, OrgNabidka3 = NULL WHERE ID = @ID;
END;
GO

