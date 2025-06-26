USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_vypocet_ceniku_kalkulace_cenik_final]    Script Date: 26.06.2025 12:50:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_vypocet_ceniku_kalkulace_cenik_final]
AS
SET NOCOUNT ON
-- =============================================
-- Author:		MŽ
-- Create date:            8.7.2019
-- Description:	Generování kusovníku (ceníku) pro označené záznamy v položkách pro kalkulaci.
-- =============================================

BEGIN

INSERT INTO TabStrukKusovnik_kalk_cenik (IDNizsi,IDZakazka,mnf,CPrirez,Autor,Dat_vypoctu,dilec,material,Vypocteny_prumer,Cena_2,Cena_dilec,Cena_vypoctena)  
        SELECT tskk.IDNizsi, tskk.IDZakazka, SUM(tskk.mnf), SUM(tskk.CPrirez), SUSER_SNAME(),GETDATE(),tskk.Dilec,tskk.Material,0,0,0,0
        FROM TabStrukKusovnik_kalk tskk
        GROUP BY tskk.IDNizsi, tskk.IDZakazka, tskk.dilec, tskk.material
END
BEGIN
DELETE FROM TabStrukKusovnik_kalk
END
GO

