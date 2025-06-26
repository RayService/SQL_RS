USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_REcalculation_CalculationMask]    Script Date: 26.06.2025 12:10:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_REcalculation_CalculationMask] @KalkKurzVal NUMERIC(19,6), @KalkSazba NUMERIC(19,6) ,@KalkPriraz INT , @KoefObch NUMERIC(19,6), @IDMask INT
AS
SET NOCOUNT ON

--DECLARE  @KalkKurzVal NUMERIC(19,6), @KalkSazba NUMERIC(19,6) ,@KalkPriraz INT , @KoefObch NUMERIC(19,6), @ID INT
--cvičné selecty (budou zadány z ext.akce)
--SELECT @ID =11058878, @KalkKurzVal =23.5, @KalkSazba = 24.3, @KalkPriraz= 15, @KoefObch = 1.25
--deklarace pro řádek položky
DECLARE @ID INT,@Dilec INT,@IDZakazka INT,@MnoPolPoz NUMERIC(19,6),@IDSkladPoz INT, @Prumer NUMERIC(19,6), @NasobitelMzdy NUMERIC(19,6), @NasobitelRezie NUMERIC(19,6),
@NakladovaCena NUMERIC(19,6), @MinCena NUMERIC(19,6), @KalkCena NUMERIC(19,6), @Material NUMERIC(19,6), @TAC NUMERIC(19,6), @TBC NUMERIC(19,6), @OptCena NUMERIC(19,6), @VyslNabCena NUMERIC(19,6), @TerminDodani NUMERIC(19,6),
@EvidCena NUMERIC(19,6), @HistProdCenaObd NUMERIC(19,6), @PocDnuHist INT,@KalkPrirazKoef NUMERIC(19,6),@NasMinCena NUMERIC(5,2), @NasOptCena NUMERIC(5,2), @DnyHistorie INT, @IDSklad NVARCHAR(30),
@MzdaCista NUMERIC (19,6), @RezieCista NUMERIC(19,6)
--úvodní kontrola
IF @KoefObch <0
BEGIN
RAISERROR ('Nelze zadat zápornou obchodní přirážku.',16,1);
RETURN;
END;

--selecty do proměnných
DECLARE Maska CURSOR LOCAL FAST_FORWARD FOR
SELECT  tpzk.ID,kob.Dilec,kob.IDZakazka,kob.MnozstviPoz
FROM Tabx_RS_KalkulaceObchodni kob
LEFT OUTER JOIN TabPozaZDok_kalk tpzk ON tpzk.ID=kob.IDPozadavku--předěláno dle ID požadavku tpzk.IDKmenZbozi=kob.Dilec AND tpzk.IDZakazka=kob.IDZakazka AND tpzk.mnozstvi=kob.MnozstviPoz
WHERE kob.ID=@IDMask
OPEN Maska;
	FETCH NEXT FROM Maska INTO @ID, @Dilec, @IDZakazka, @MnoPolPoz;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

SELECT @IDSkladPoz=tpzk.IDZboSklad, @Prumer=tss.Prumer
FROM TabPozaZDok_kalk tpzk
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=tpzk.IDZboSklad
WHERE tpzk.ID=@ID

SELECT @NasobitelMzdy=ISNULL(NasobitelMzdy,0), @NasobitelRezie=ISNULL(NasobitelRezie,0)
FROM Tabx_RS_RozsahPoctuKusu
WHERE (@MnoPolPoz> KusyOd AND @MnoPolPoz<=KusyDo)
--SELECT NasMinCena, NasOptCena, DnyHistorie, IDSklad FROM Tabx_RS_KalkulaceKonfig

SELECT @MzdaCista=ISNULL((tzk.TAC_KC+tzk.TBC_KC),0), @RezieCista = ISNULL(tzk.rezieS,0)
FROM Tabx_RS_ZKalkulace tzk
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=tzk.CisloZakazky
WHERE tzk.Dilec=@Dilec AND tz.ID=@IDZakazka

SELECT @NakladovaCena=((ISNULL(tzk.mat,0)+ISNULL(tzk.OPN,0)+ISNULL(tzk.koop,0))+(tzk.TAC_KC+tzk.TBC_KC)*@NasobitelMzdy+(tzk.rezieS)*@NasobitelRezie)
FROM Tabx_RS_ZKalkulace tzk
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=tzk.CisloZakazky
WHERE tzk.Dilec=@Dilec AND tz.ID=@IDZakazka

SELECT @MinCena=(@NakladovaCena*NasMinCena), @PocDnuHist=DnyHistorie, @NasMinCena=NasMinCena, @NasOptCena=NasOptCena, @DnyHistorie=DnyHistorie, @IDSklad=IDSklad
FROM Tabx_RS_KalkulaceKonfig

SET @KalkPrirazKoef=1+(CONVERT(NUMERIC(19,6),@KalkPriraz)/100)

SELECT @KalkCena=(((ISNULL(tzk.TAC,0)/CASE tzk.TAC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END)+(ISNULL(tzk.TBC,0)/CASE tzk.TBC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END))*@KalkSazba*@KalkKurzVal)+((ISNULL(tzk.mat,0)+ISNULL(tzk.OPN,0)+ISNULL(tzk.koop,0))*@KalkPrirazKoef)
FROM Tabx_RS_ZKalkulace tzk
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=tzk.CisloZakazky
WHERE tzk.Dilec=@Dilec AND tz.ID=@IDZakazka

--MŽ, 14.6.2022, nové selecty
SELECT @Material=ISNULL(tzk.mat,0)+ISNULL(tzk.OPN,0)+ISNULL(tzk.koop,0)
FROM Tabx_RS_ZKalkulace tzk
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=tzk.CisloZakazky
WHERE tzk.Dilec=@Dilec AND tz.ID=@IDZakazka

SELECT @TAC=ISNULL(tzk.TAC,0)/CASE tzk.TAC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END
FROM Tabx_RS_ZKalkulace tzk
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=tzk.CisloZakazky
WHERE tzk.Dilec=@Dilec AND tz.ID=@IDZakazka

SELECT @TBC=ISNULL(tzk.TBC,0)/CASE tzk.TBC_T WHEN 0 THEN 3600.0 WHEN 1 THEN 60.0 WHEN 2 THEN 1.0 END
FROM Tabx_RS_ZKalkulace tzk
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=tzk.CisloZakazky
WHERE tzk.Dilec=@Dilec AND tz.ID=@IDZakazka

--pokračování
SELECT @OptCena=@NakladovaCena*NasOptCena
FROM Tabx_RS_KalkulaceKonfig

SELECT @VyslNabCena = ROUND(@NakladovaCena*(1+(ISNULL(@KoefObch,0)/100)),2)/*změna 14.6.2022, původně bylo: @OptCena * @KoefObch*/

SELECT @TerminDodani=(SELECT /*MAX(tskk.Dokl_poptLT),*/MAX(tkze._EXT_RS_dodaci_lhuta_tydny)
FROM TabDetailniKalkulace_kalk tkk --Detailní kalkulace
LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik tskk WITH(NOLOCK) ON tskk.IDNizsi=tkk.IDNizsi AND tskk.IDZakazka=tkk.IDZakazka-- AND tskk.Autor=tkk.Autor
LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tskk.IDNizsi
WHERE tkk.IDVyssi=@Dilec AND tkk.TypRadku IN (10,20) AND tkk.IDZakazka=@IDZakazka-- AND tkk.Autor=tskk.Autor --AND tkk.Autor=SUSER_SNAME()
)

SELECT @EvidCena=tss.Prumer
FROM TabStavSkladu tss
WHERE tss.IDKmenZbozi=@Dilec AND tss.IDSklad='200'

SELECT @HistProdCenaObd=AVG(tpz.JCBezDaniKc)
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
WHERE tdz.DruhPohybuZbo=13 AND tdz.DatPorizeni>=GETDATE()-@PocDnuHist AND tkz.ID=@Dilec

--vložení hodnoty do kalkulační masky
--IF EXISTS(SELECT * FROM Tabx_RS_KalkulaceObchodni WHERE (Dilec=@Dilec) AND (IDZakazka=@IDZakazka) AND (MnozstviPoz=@MnoPolPoz))
IF EXISTS(SELECT * FROM Tabx_RS_KalkulaceObchodni WHERE IDPozadavku=@ID)
BEGIN
UPDATE tko SET NakladovaCena=@NakladovaCena,MinCena=@MinCena,KalkCena=@KalkCena,Material=@Material,TAC=@TAC,TBC=@TBC, OptCena=@OptCena,VyslNabCena=ROUND(@VyslNabCena,2),TerminDodani=@TerminDodani
,EvidCena=@EvidCena,HistProdCenaObd=@HistProdCenaObd,KalkKurzVal=@KalkKurzVal,KalkSazba=@KalkSazba,KalkPriraz=@KalkPriraz,KoefObch=@KoefObch,Zmenil=SUSER_SNAME(),DatZmeny=GETDATE()
,NasMinCena=@NasMinCena, NasOptCena=@NasOptCena, DnyHistorie=@DnyHistorie, IDSklad=@IDSklad,NasobitelMzdy=@NasobitelMzdy,NasobitelRezie=@NasobitelRezie,MzdaCista=@MzdaCista,RezieCista=@RezieCista
FROM Tabx_RS_KalkulaceObchodni tko
WHERE tko.ID=@IDMask --(Dilec=@Dilec) AND (IDZakazka=@IDZakazka) AND (MnozstviPoz=@MnoPolPoz)
END
/* nemám co ELSE, bo stojím na řádku masky
ELSE
BEGIN
INSERT INTO Tabx_RS_KalkulaceObchodni (Dilec,IDZakazka,MnozstviPoz,NakladovaCena,MinCena,KalkCena,Material,TAC,TBC,OptCena,VyslNabCena,TerminDodani,EvidCena,HistProdCenaObd,KalkKurzVal,KalkSazba,KalkPriraz,KoefObch) 
VALUES (@Dilec,@IDZakazka,@MnoPolPoz,@NakladovaCena,@MinCena,@KalkCena,@Material,@TAC,@TBC,@OptCena,@VyslNabCena,@TerminDodani,@EvidCena,@HistProdCenaObd,@KalkKurzVal,@KalkSazba,@KalkPriraz,@KoefObch)
END
*/

	-- konec akce v kurzoru Maska
	FETCH NEXT FROM Maska INTO @ID, @Dilec, @IDZakazka, @MnoPolPoz;
	END;
CLOSE Maska;
DEALLOCATE Maska;
GO

