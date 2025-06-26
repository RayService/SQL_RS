USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_doplneni_ceny_poznamky_do_ceniku]    Script Date: 26.06.2025 14:17:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_doplneni_ceny_poznamky_do_ceniku]
@ID INT
AS
SET NOCOUNT ON
-- =====================================================================================================
-- Author:		MŽ
-- Create date:            10.10.2019
-- Description:	Do označených řádků se doplní cena z nabídek. Dohledá se nejnižší cena a poznámka z daného pohybu a oba údaje se propíší do ceníku.
-- =====================================================================================================

DECLARE @Cislo_zak NVARCHAR(15) = (SELECT CisloZakazky FROM TabZakazka LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik ON TabStrukKusovnik_kalk_cenik.IDZakazka = TabZakazka.ID WHERE TabStrukKusovnik_kalk_cenik.ID = @ID);
DECLARE @Nejnizsi_cena NUMERIC(19,6) = (SELECT TOP 1 MIN(tpz.JCbezDaniKC)
										FROM TabStrukKusovnik_kalk_cenik tskkc
										LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
										LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
										WHERE ((tpz.IDZboSklad = tss.ID)AND(tdz.CisloZakazky=@Cislo_zak)AND(tdz.DruhPohybuZbo=11)AND(tpz.JCbezDaniKC>0)AND(tskkc.ID = @ID)))
DECLARE @Poznamka NVARCHAR(MAX) = (SELECT TOP 1 tpz.Poznamka
FROM TabStrukKusovnik_kalk_cenik tskkc
	LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
	LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
	LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
WHERE
((tpz.IDZboSklad = tss.ID)AND(tdz.DruhPohybuZbo=11)AND(tpz.JCbezDaniKC>0)AND(tskkc.ID = @ID)AND(tdz.CisloZakazky=@Cislo_zak)AND(tpz.JCbezDaniKC=(SELECT MIN(tpz.JCbezDaniKC)
										FROM TabStrukKusovnik_kalk_cenik tskkc
										LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
										LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
										WHERE ((tpz.IDZboSklad = tss.ID)AND(tdz.CisloZakazky=@Cislo_zak)AND(tdz.DruhPohybuZbo=11)AND(tpz.JCbezDaniKC>0)AND(tskkc.ID = @ID)))))
)
--MŽ, 28.7.2020 rozšířeno dotahování MOQ a Dodací termín týdny z položky dokladu, stejně jako poznámka
DECLARE @_poptMOQ NUMERIC(19,6) = (SELECT TOP 1 tpze._poptMOQ
FROM TabStrukKusovnik_kalk_cenik tskkc
	LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
	LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
	LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID = tpz.ID
	LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
WHERE
((tpz.IDZboSklad = tss.ID)AND(tdz.DruhPohybuZbo=11)AND(tpz.JCbezDaniKC>0)AND(tskkc.ID = @ID)AND(tpz.JCbezDaniKC=(SELECT MIN(tpz.JCbezDaniKC)
										FROM TabStrukKusovnik_kalk_cenik tskkc
										LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
										LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
										WHERE ((tpz.IDZboSklad = tss.ID)AND(tdz.CisloZakazky=@Cislo_zak)AND(tdz.DruhPohybuZbo=11)AND(tpz.JCbezDaniKC>0)AND(tskkc.ID = @ID)))))
)
DECLARE @_poptLT NUMERIC(19,6) = (SELECT TOP 1 tpze._poptLT
FROM TabStrukKusovnik_kalk_cenik tskkc
	LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
	LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
	LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID = tpz.ID
	LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
WHERE
((tpz.IDZboSklad = tss.ID)AND(tdz.DruhPohybuZbo=11)AND(tpz.JCbezDaniKC>0)AND(tskkc.ID = @ID)AND(tpz.JCbezDaniKC=(SELECT MIN(tpz.JCbezDaniKC)
										FROM TabStrukKusovnik_kalk_cenik tskkc
										LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
										LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
										WHERE ((tpz.IDZboSklad = tss.ID)AND(tdz.CisloZakazky=@Cislo_zak)AND(tdz.DruhPohybuZbo=11)AND(tpz.JCbezDaniKC>0)AND(tskkc.ID = @ID)))))
)
--je-li to materiál, proběhne doplnění ceny z nabídky a uložení do Cena_vypoctena
--MŽ, 4.11.2019 upraveno tak, aby se nepřepisovala Cena_vypoctena, ale pouze se zapisovalo do Cena_doklad a Poznamka_dokl
--MŽ, 28.7.2020 rozšířeno dotahování MOQ a Dodací termín týdny z položky dokladu, stejně jako poznámka
IF (SELECT material FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET /*Cena_vypoctena =@Nejnizsi_cena,*/Cena_doklad=@Nejnizsi_cena, Poznamka_dokl=@Poznamka, Dokl_poptMOQ=@_poptMOQ, Dokl_poptLT=@_poptLT FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
GO

