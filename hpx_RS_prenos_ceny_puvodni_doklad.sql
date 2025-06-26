USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_prenos_ceny_puvodni_doklad]    Script Date: 26.06.2025 12:11:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--Tato uložená procedura přepočítá ceny všech původních pohybů, které k dané kalkulační masce patří.

CREATE PROCEDURE [dbo].[hpx_RS_prenos_ceny_puvodni_doklad]
@kontrola BIT,
@IDMask INT
AS
SET NOCOUNT ON
--DECLARE @kontrola BIT=1, @IDMask INT=18
IF @kontrola=1
BEGIN
DECLARE @ID INT,@Dilec INT,@IDZakazka INT,@MnoPolPoz NUMERIC(19,6), @VyslNabCena NUMERIC(19,6),@VyslNabCenaVal NUMERIC(19,6), @IDPohyb INT, @VstupniCena INT, @IDDoklad INT, @KurzMask NUMERIC(19,6), @DruhPohybuZbo TINYINT
--selecty do proměnných
SELECT @VyslNabCena=VyslNabCena, @KurzMask=KalkKurzVal
FROM Tabx_RS_KalkulaceObchodni kob
WHERE kob.ID=@IDMask

DECLARE Maska CURSOR LOCAL FAST_FORWARD FOR
SELECT  tpzk.ID,kob.Dilec,kob.IDZakazka,kob.MnozstviPoz
FROM Tabx_RS_KalkulaceObchodni kob
LEFT OUTER JOIN TabPozaZDok_kalk tpzk ON tpzk.ID=kob.IDPozadavku--nově předěláno na vazba dle IDpožadavku tpzk.IDKmenZbozi=kob.Dilec AND tpzk.IDZakazka=kob.IDZakazka AND tpzk.mnozstvi=kob.MnozstviPoz
WHERE kob.ID=@IDMask
OPEN Maska;
	FETCH NEXT FROM Maska INTO @ID, @Dilec, @IDZakazka, @MnoPolPoz;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
		SELECT @IDPohyb=tpzk.IDPohyb, @IDDoklad=tpzk.IDDoklad
		FROM TabPozaZDok_kalk tpzk
		WHERE tpzk.ID=@ID
		SELECT @VstupniCena=tpz.VstupniCena
		FROM TabPohybyZbozi tpz
		WHERE tpz.ID=@IDPohyb
		SELECT @DruhPohybuZbo = tdz.DruhPohybuZbo
		FROM TabDokladyZbozi tdz
		WHERE tdz.ID=@IDDoklad
		--SELECT @ID AS IDPolProKal, @Dilec AS IDDilce, @IDZakazka AS IDZakazka, @MnoPolPoz AS MnoPol
		--SELECT @IDPohyb AS IDPohybu, @VstupniCena AS VstupniCena, @IDDoklad AS IDDoklad
		--zkopírování výsledné nab.ceny do orig.pohybu
		--kontrola na připojení schvalovacího předpisu, pokud je připojen - pryč
		IF EXISTS(SELECT * FROM Tabx_SDPredpisy WHERE ISNULL(Tabx_SDPredpisy.Kopie, 0)=1 AND Tabx_SDPredpisy.TypDokladu=0 AND Tabx_SDPredpisy.IdDoklad=@IDDoklad)
		BEGIN
		RAISERROR ('Na původním dokladu je připojen schvalovací předpis, akce neproběhne.',16,1)
		RETURN
		END;
		--kontrola na druh pohybu původního dokladu, pokud je EP - pryč
		IF @DruhPohybuZbo=9
		BEGIN
		RAISERROR ('Původní doklad je Expediční příkaz, nelze měnit!',16,1)
		RETURN
		END;
		IF @VstupniCena=0
			BEGIN
			UPDATE tpz SET JCbezDaniKC=ROUND(@VyslNabCena,2) FROM TabPohybyZbozi tpz WHERE tpz.ID=@IDPohyb
			EXEC hp_VypCenOZPolozek_IDPolozky @IDPolozky=@IDPohyb,@AktualizaceSlev=1,@Pozice=NULL,@Hranice=NULL,@VstupniCena=0
			END
			--dopočet cen na dokladu
			EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1
		IF @VstupniCena=4
			BEGIN
			UPDATE tpz SET JCbezDaniVal=ROUND(@VyslNabCena/@KurzMask,2) FROM TabPohybyZbozi tpz WHERE tpz.ID=@IDPohyb
			EXEC hp_VypCenOZPolozek_IDPolozky @IDPolozky=@IDPohyb,@AktualizaceSlev=1,@Pozice=NULL,@Hranice=NULL,@VstupniCena=4
			END
			--dopočet cen na dokladu
			EXEC dbo.hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1
	-- konec akce v kurzoru Maska
	FETCH NEXT FROM Maska INTO @ID, @Dilec, @IDZakazka, @MnoPolPoz;
	END;
CLOSE Maska;
DEALLOCATE Maska;
END;
ELSE
BEGIN
RAISERROR ('Akce neproběhne, není nic zatrženo!',16,1)
END
GO

