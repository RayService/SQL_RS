USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_new_item_pricing_list_order]    Script Date: 26.06.2025 11:59:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_new_item_pricing_list_order]
@ID INT
AS
--DECLARE @ID INT=5583702
BEGIN
INSERT INTO TabStrukKusovnik_kalk_cenik (IDZakazka, IDNizsi, mnf, dilec, material, Dat_vypoctu, Autor, Vypocteny_prumer,Cena_2,Cena_dilec,Cena_vypoctena)
SELECT tz.ID,tkz.ID,tpz.Mnozstvi,tkz.Dilec, tkz.Material, GETDATE(), SUSER_SNAME(), 0,0,0,0
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
JOIN TabZakazka tz ON tz.CisloZakazky=tdz.CisloZakazky
WHERE tpz.ID=@ID
END





GO

