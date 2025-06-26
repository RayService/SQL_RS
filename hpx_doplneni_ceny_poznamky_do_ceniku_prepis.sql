USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_doplneni_ceny_poznamky_do_ceniku_prepis]    Script Date: 26.06.2025 11:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_doplneni_ceny_poznamky_do_ceniku_prepis]
@ID INT
AS
SET NOCOUNT ON
-- =====================================================================================================
-- Author:		MŽ
-- Create date:            4.11.2019
-- Description:	Do označených řádků se doplní do Cena_vypoctena políčko Cena_doklad
-- =====================================================================================================

--je-li to materiál, proběhne přepis z ceny Cena_doklad do Cena_vypoctena
--IF (SELECT material FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena =Cena_doklad FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
GO

