USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_DoplneniCenyPoznamkyDoCenikuDleLT]    Script Date: 26.06.2025 15:53:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_DoplneniCenyPoznamkyDoCenikuDleLT]
@ID INT
AS
SET NOCOUNT ON
-- =====================================================================================================
-- Author:		MŽ
-- Create date:            29.10.2024
-- Description:	Do označených řádků se doplní cena, poznámka a LT z nabídek. Dohledá se nejnižší termín (_poptLT) a dohledá se cena, poznámka, MOQ a LT z daného pohybu a propíše se do řádku ceníku
-- =====================================================================================================
DECLARE @Cislo_zak NVARCHAR(15) = (SELECT CisloZakazky FROM TabZakazka LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik ON TabStrukKusovnik_kalk_cenik.IDZakazka = TabZakazka.ID WHERE TabStrukKusovnik_kalk_cenik.ID = @ID);
DECLARE @IDPohyb INT, @_poptLT NUMERIC(19,6), @Poznamka NVARCHAR(MAX), @_poptMOQ NUMERIC(19,6)
DECLARE @Nejnizsi_cena NUMERIC(19,6)

SET @IDPohyb=(SELECT TOP 1 tpz.ID
FROM TabStrukKusovnik_kalk_cenik tskkc
	LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
	LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
	LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID = tpz.ID
	LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
WHERE
((tpz.IDZboSklad = tss.ID)AND(tdz.DruhPohybuZbo=11)AND(tdz.CisloZakazky=@Cislo_zak)AND(tpz.JCbezDaniKC>0)AND(tskkc.ID = @ID)AND(tpze._poptLT=(SELECT MIN(tpze._poptLT)
										FROM TabStrukKusovnik_kalk_cenik tskkc
										LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi = tskkc.IDNizsi  AND tss.IDSklad = '100'
										LEFT OUTER JOIN TabPohybyZbozi tpz ON tpz.IDZboSklad = tss.ID
										LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID = tpz.ID
										LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
										WHERE ((tpz.IDZboSklad = tss.ID)AND(tdz.CisloZakazky=@Cislo_zak)AND(tdz.DruhPohybuZbo=11)AND(tpz.JCbezDaniKC>0)AND(tpze._poptLT IS NOT NULL)AND(tskkc.ID = @ID)))))
)
--dotáhnout dle @IDPohyb
SELECT @_poptLT=tpze._poptLT, @Nejnizsi_cena=tpz.JCbezDaniKC, @Poznamka=tpz.Poznamka, @_poptMOQ=tpze._poptMOQ
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
WHERE tpz.ID=@IDPohyb

--je-li to materiál, proběhne doplnění ceny z nabídky a uložení do Cena_vypoctena
--MŽ, 4.11.2019 upraveno tak, aby se nepřepisovala Cena_vypoctena, ale pouze se zapisovalo do Cena_doklad a Poznamka_dokl
--MŽ, 28.7.2020 rozšířeno dotahování MOQ a Dodací termín týdny z položky dokladu, stejně jako poznámka
IF (SELECT material FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_doklad=@Nejnizsi_cena, Poznamka_dokl=@Poznamka, Dokl_poptMOQ=@_poptMOQ, Dokl_poptLT=@_poptLT FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
GO

