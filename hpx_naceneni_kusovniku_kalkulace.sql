USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_naceneni_kusovniku_kalkulace]    Script Date: 26.06.2025 12:34:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_naceneni_kusovniku_kalkulace]
@ID INT
AS
SET NOCOUNT ON
-- =============================================
-- Author:		MŽ
-- Create date:            3.6.2019
-- Description:	Výpočet ceny v kalkulaci
-- Change MŽ 17.8.2021
-- =============================================

--zjištění hodnot pro výpočet cen
DECLARE @Vypocteny_prumer NUMERIC(19,6) = (SELECT ISNULL(ISNULL(tss.Prumer, tss100.Prumer),0)
										FROM TabStrukKusovnik_kalk_cenik tskk
										LEFT OUTER JOIN TabParametryKmeneZbozi pkz ON pkz.IDKmenZbozi=tskk.IDNizsi
										LEFT OUTER JOIN TabStavSkladu tss ON tss.IDSklad=pkz.VychoziSklad AND tss.IDKmenZbozi=tskk.IDNizsi
										LEFT OUTER JOIN TabStavSkladu tss100 ON tss100.IDSklad='100' AND tss100.IDKmenZbozi=tskk.IDNizsi
										WHERE tskk.ID = @ID)
DECLARE @Cena_2 NUMERIC(19,6) = (SELECT ISNULL(cena2,0) FROM TabKalkCe tkc LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik tskk ON tskk.IDNizsi = tkc.IDKmenZbozi WHERE tskk.ID = @ID AND tkc.ZmenaDo IS NULL)
DECLARE @Cena_dilec NUMERIC(19,6) = (SELECT ISNULL(NULLIF(Celkem,0),0.01) FROM TabZKalkulace tzk LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik tskk ON tskk.IDNizsi = tzk.Dilec AND tzk.ZmenaDo IS NULL WHERE tskk.ID = @ID)
DECLARE @OPN_dilec NUMERIC(19,6) = (SELECT OPN FROM TabZKalkulace tzk LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik tskk ON tskk.IDNizsi = tzk.Dilec AND tzk.ZmenaDo IS NULL WHERE tskk.ID = @ID)
DECLARE @koop_dilec NUMERIC(19,6) = (SELECT koop FROM TabZKalkulace tzk LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik tskk ON tskk.IDNizsi = tzk.Dilec AND tzk.ZmenaDo IS NULL WHERE tskk.ID = @ID)
DECLARE @VD_dilec NVARCHAR(3) = (SELECT ts.K1 FROM TabStrukKusovnik_kalk_cenik tskk WITH(NOLOCK)
						JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tskk.IDNizsi
						LEFT OUTER JOIN TabSortiment ts WITH(NOLOCK) ON ts.ID=tkz.IdSortiment
						WHERE tkz.Dilec=1 AND tskk.ID = @ID)

--uložení zjištěných hodnot
BEGIN
UPDATE TabStrukKusovnik_kalk_cenik SET Vypocteny_prumer = @Vypocteny_prumer, Cena_2 = @Cena_2, Cena_dilec = @Cena_dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
--uložení zjištěných hodnot pro dílec
-- MŽ 117.8.2021 doplnit podmínku: je-li to dílec, vlož do Vypočtené kalkulační ceny cenu kooperace.
BEGIN
UPDATE TabStrukKusovnik_kalk_cenik SET OPN_kalk=@OPN_dilec, koop_kalk=@koop_dilec, Cena_vypoctena=@koop_dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
--uložení VD
IF @VD_dilec = 'VD'
BEGIN
UPDATE TabStrukKusovnik_kalk_cenik SET VD=1 FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
ELSE
BEGIN
UPDATE TabStrukKusovnik_kalk_cenik SET VD=0 FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END


--je-li to materiál, proběhne nacenění a uložení do Cena_vypoctena
IF (SELECT material FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1 AND @Vypocteny_prumer <> 0
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena =@Vypocteny_prumer FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
IF (SELECT material FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1 AND @Vypocteny_prumer = 0 AND @Cena_2 <> 0
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena =@Cena_2 FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
IF (SELECT material FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1 AND @Cena_2 = 0 AND @Vypocteny_prumer = 0
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena = @Vypocteny_prumer FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
/*MŽ 17.8.2021 
--je-li to dílec, proběhne zjištění kalkulační ceny a uložení do sloupce Cena_dilec, pokud je cena dílce 0 tak dát 0.01
Nahradit podmínkou: je-li to dílec, proběhne zjištění kalkulační ceny a uložení do sloupce Cena_dilec, pokud je cena dílce 0 tak dát 0.01 nepřepisovat do vypočetené kalkulační ceny.
Toto je zajištěno již výše.
IF (SELECT dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena = @Cena_dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END*/
--je-li to dílec, VD a vypočtený průměr je <> 0, tak vypočtený průměr
--MŽ, 4.7.2022 vyřazena podmínka na VD
IF ((SELECT dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
/*AND (SELECT VD FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1*/
AND (SELECT Vypocteny_prumer FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) <> 0)
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena = @Vypocteny_prumer FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END

--MŽ, 4.7.2022, je-li to dílec, vypočtený průměr = 0, tak Cena polotovar (@Cena_dilec) do výsledné ceny
IF ((SELECT dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
AND (SELECT Vypocteny_prumer FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 0)
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena = @Cena_dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END

/*
--MŽ, 4.7.2022 úplně zrušeno
--je-li to dílec, VD a vypočtený průměr je = 0 a OPN <>, tak OPN
IF ((SELECT dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
AND (SELECT VD FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
AND (SELECT Vypocteny_prumer FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 0)
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena = @OPN_dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
--je-li to dílec, VD a vypočtený průměr je = 0 a OPN = 0, tak nastavit 0.
IF ((SELECT dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
AND (SELECT VD FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
AND (SELECT Vypocteny_prumer FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 0
AND (SELECT OPN_kalk FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 0)
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena = 0 FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END
*/
/*MŽ 17.8.2021 toto zrušeno
--je-li to dílec, není VD a koop <> 0, tak koop
IF ((SELECT dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) = 1
AND (SELECT VD FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) <> 1
AND (SELECT koop_kalk FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID) <> 0)
BEGIN
    UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena = @koop_dilec FROM TabStrukKusovnik_kalk_cenik WHERE TabStrukKusovnik_kalk_cenik.ID = @ID
END*/
GO

