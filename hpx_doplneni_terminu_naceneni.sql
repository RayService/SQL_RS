USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_doplneni_terminu_naceneni]    Script Date: 26.06.2025 11:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[hpx_doplneni_terminu_naceneni]
@kontrola BIT,
@Termin_naceneni DATETIME
AS
-- =============================================
-- Author:		MŽ
-- Create date:            29.7.2020
-- Description:	Doplnění termínu nacenění
-- Update: 8.9.2022 Funkce zásadně předělána o generování nové operace do VP pro nacenění.
/*
Po importu položky do kusovníku - ceníku z nabídky automaticky generovat VP s operací pro vykazování BONu.
Řada VP 909. Jedna operace. Název Ceník.
Za každou zakázku vygenerovat nový VP a dát do hlavičky zakázku..
Čas na operaci spočítat : součet množství položek pro danou zakázku krát položkový čas (dodá LM, materiál = 2 min, dílec = 5 min).
*/
-- =============================================

/*
--deklarace z ext.akce
DECLARE @kontrola BIT,
@Termin_naceneni DATETIME
SELECT @kontrola=1,@Termin_naceneni='2022-05-18'--,@ID=218511
*/
--deklarace procedury
DECLARE @TypDilce NVARCHAR(2), @IDTypOperace INT, @IDZakazky INT;
DECLARE @IDDilceNewVP INT=23340;
DECLARE @IDPrikaz INT;
DECLARE @IDOper INT;
DECLARE @DatumOper DATETIME;
DECLARE @NewIDPrikaz INT;
DECLARE @NewIDOper INT;
DECLARE @retmaznapojeni INT;
DECLARE @retmazoper INT;
DECLARE @Odchylka INT;

--není-li zatrženo Přepsat, do kopru..
IF @kontrola=0
BEGIN
RAISERROR('Není zatrženo Přepsat, nic neproběhne.',16,1)
RETURN;
END;

IF @kontrola=1
BEGIN

/*
--cvičná deklarace dočasné tabulky, jinak řeší HEO:
IF (OBJECT_ID('tempdb..#TabExtKomID') IS NOT NULL)
BEGIN
DROP TABLE #TabExtKomID
END;
CREATE TABLE #TabExtKomID 
( [ID] INT
)

INSERT INTO #TabExtKomID (ID)
VALUES (122397),(116480),(115084),(143154)
*/
IF (OBJECT_ID('tempdb..#TabTempZak') IS NOT NULL)
BEGIN
DROP TABLE #TabTempZak
END;
CREATE TABLE #TabTempZak 
( [ID] INT,
[IDZak] INT,
[MnoPol] NUMERIC(19,6),
[TypDilce] NVARCHAR(2)
)
INSERT INTO #TabTempZak (ID,IDZak,MnoPol,TypDilce)
SELECT ext.ID,cen.IDZakazka,cen.mnf,CASE WHEN (cen.dilec=1 OR cen.VD=1) THEN 'D' WHEN cen.material=1 THEN 'M' ELSE NULL END
FROM #TabExtKomID ext
LEFT OUTER JOIN TabStrukKusovnik_kalk_cenik cen ON cen.ID=ext.ID

IF EXISTS(
SELECT T.*
FROM (
SELECT IDZak,RANK() OVER (ORDER BY IDZak) AS rn
FROM #TabTempZak) AS T
WHERE T.rn>1)
BEGIN
RAISERROR('Máte označeno více zakázek, nelze provést.',16,1)
RETURN;
END;

IF EXISTS(
SELECT IDZak
FROM #TabTempZak
LEFT OUTER JOIN TabZakazka tz ON tz.ID=IDZak
WHERE tz.Ukonceno<>0)
BEGIN
RAISERROR('Máte označenu uzavřenou zakázku, nelze provést.',16,1)
RETURN;
END;

IF @Termin_naceneni IS NULL
GOTO NOTERMIN;

/*
--dohledání typu položky, zakázky
SELECT @TypDilce=CASE WHEN (dilec=1 OR VD=1) THEN 'D' WHEN material=1 THEN 'M' ELSE NULL END, @IDZakazky=IDZakazka
FROM TabStrukKusovnik_kalk_cenik tskk
WHERE tskk.ID=@ID
*/

--tady musím začít kurzorem za grupované řádky #TabTempZak
DECLARE @PocetPol INT;
DECLARE CurPolZak CURSOR LOCAL FAST_FORWARD FOR 
SELECT IDZak,TypDilce,COUNT(ID)
FROM #TabTempZak
GROUP BY IDZak,TypDilce;
OPEN CurPolZak;
	FETCH NEXT FROM CurPolZak INTO @IDZakazky, @TypDilce, @PocetPol;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

	--kontrola, pokud náhodou není víc VP se stejnou zakázkou a dílcem
	IF (SELECT COUNT(tp.ID)
	FROM TabPrikaz tp
	WHERE tp.IDZakazka=@IDZakazky AND tp.IDTabKmen=@IDDilceNewVP AND tp.Rada='909' AND tp.StavPrikazu<=30)>1
	BEGIN
	RAISERROR('Existuje více živých VP pro přezkoumání poptávky k zadané zakázce, nelze pokračovat.',16,1)
	RETURN;
	END;
	
	--dohledání, zda již existuje VP na stejnou zakázku
	SET @IDPrikaz=(SELECT tp.ID
	FROM TabPrikaz tp
	WHERE tp.IDZakazka=@IDZakazky AND tp.IDTabKmen=@IDDilceNewVP AND tp.Rada='909' AND tp.StavPrikazu<=30)
	--dohledání, zda již existuje operace ceník(vd) pro daný termín
	SET @IDOper=(CASE 
	WHEN @TypDilce = 'M' THEN (SELECT tpp.ID
	FROM TabPrPostup tpp
	LEFT OUTER JOIN TabPrikaz tp ON tpp.IDPrikaz=tp.ID
	WHERE (tpp.IDOdchylkyDo IS NULL)AND(tpp.nazev=N'ceník')AND(tp.IDZakazka=@IDZakazky)AND(tpp.Splneno=0)AND(tp.IDTabKmen=@IDDilceNewVP)AND(tp.Rada='909')AND(tpp.Plan_ukonceni=@Termin_naceneni)AND(tp.ID=@IDPrikaz))
	WHEN @TypDilce = 'D' THEN (SELECT tpp.ID
	FROM TabPrPostup tpp
	LEFT OUTER JOIN TabPrikaz tp ON tpp.IDPrikaz=tp.ID
	WHERE (tpp.IDOdchylkyDo IS NULL)AND(tpp.nazev=N'Ceník VD')AND(tp.IDZakazka=@IDZakazky)AND(tpp.Splneno=0)AND(tp.IDTabKmen=@IDDilceNewVP)AND(tp.Rada='909')AND(tpp.Plan_ukonceni=@Termin_naceneni)AND(tp.ID=@IDPrikaz))
	ELSE NULL END)
	
	SET @Odchylka=(SELECT TOP 1 ID FROM TabCOdchylek WHERE PermanentniOdchylka=1)
	
	--pokud existuje příkaz a operace s datem = pryč
	IF @IDPrikaz IS NOT NULL AND @IDOper IS NOT NULL AND @TypDilce='M'
		BEGIN
		RAISERROR('Existuje již operace Ceník pro nacenění se stejnou zakázkou a požadovaným termínem, nelze zapsat.',16,1)
		RETURN;
		END;
	IF @IDPrikaz IS NOT NULL AND @IDOper IS NOT NULL AND @TypDilce='D'
		BEGIN
		RAISERROR('Existuje již operace Ceník VD pro nacenění se stejnou zakázkou a požadovaným termínem, nelze zapsat.',16,1)
		RETURN;
	END;
	
	--pokud existuje příkaz a není operace s datem = založím novou
	IF @IDPrikaz IS NOT NULL AND @IDOper IS NULL
	--vložení nové operace
	--zde nutno dodat od LM cifry (2 minuty na materiál, 5 minut na dílec)
	BEGIN
		SELECT @IDTypOperace = CASE WHEN @TypDilce = 'M' THEN 381 WHEN @TypDilce = 'D' THEN 383 ELSE NULL END
		EXEC @NewIDOper=hp_NewPozadavek_TabPrPostup @IDPrikaz=@IDPrikaz, @IDTypoveOperace=@IDTypOperace
		UPDATE TabPrPostup SET Plan_ukonceni=@Termin_naceneni WHERE ID=@NewIDOper
		UPDATE TabPrPostup SET
		TAC_T=1,
		TAC_J_T=1,
		TAC_Obsluhy_J_T=1, 
		TAC=CASE WHEN @TypDilce='M' THEN 2*@PocetPol ELSE 5*@PocetPol END,
		TAC_J=CASE WHEN @TypDilce='M' THEN 2*@PocetPol ELSE 5*@PocetPol END,
		TAC_Obsluhy=CASE WHEN @TypDilce='M' THEN 2*@PocetPol ELSE 5*@PocetPol END,
		TAC_Obsluhy_J=CASE WHEN @TypDilce='M' THEN 2*@PocetPol ELSE 5*@PocetPol END
		WHERE ID=@NewIDOper
	END;
	--pokud není ani příkaz = založím nový, vložím novou operaci
	IF @IDPrikaz IS NULL
	BEGIN
	EXEC @NewIDPrikaz=hp_NewVyrobniPrikaz @Rada='909', @IDDilce=@IDDilceNewVP, @kusy_ciste=1.0, @IDZakazka=@IDZakazky, @Plan_ukonceni=@Termin_naceneni
	--zadání nového VP
	EXEC hp_ZadaniPrikazuDoVyroby @IDPrikaz=@NewIDPrikaz, @OnlyPredzpracovani=0

	--mazání všech operací z nového VP cursorem
	DECLARE @IDOperSmaz INT, @CisOperSmaz NCHAR(4), @DokladOperSmaz INT;
	DECLARE CurSmazOper CURSOR LOCAL FAST_FORWARD FOR 
	SELECT tpp.ID,tpp.Operace,tpp.Doklad
	FROM TabPrPostup tpp
	LEFT OUTER JOIN TabPrikaz tp ON tpp.IDPrikaz=tp.ID
	WHERE ((tpp.IDOdchylkyDo IS NULL)AND(tp.IDZakazka=@IDZakazky))
	OPEN CurSmazOper;
		FETCH NEXT FROM CurSmazOper INTO @IDOperSmaz, @CisOperSmaz, @DokladOperSmaz;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			EXEC @retmaznapojeni=hp_ZrusNapojeniVyrPozadavkuNaVyrOperaci @Zpusob=0, @IDPrikaz=@NewIDPrikaz, @Dilec=@IDDilceNewVP, @Operace=@CisOperSmaz, @Alt=NULL, @IDOdchNew=@Odchylka
			EXEC @retmazoper=hp_TabPrPostup_Delete @IDPrikaz=@NewIDPrikaz, @Doklad=@DokladOperSmaz, @Alt=N'A', @IDOdchNew=@Odchylka
		FETCH NEXT FROM CurSmazOper INTO @IDOperSmaz, @CisOperSmaz, @DokladOperSmaz;
		END;
	CLOSE CurSmazOper;
	DEALLOCATE CurSmazOper;

	--vložení nové operace ceník(vd)
	SELECT @IDTypOperace = CASE WHEN @TypDilce = 'M' THEN 381 WHEN @TypDilce = 'D' THEN 383 ELSE NULL END
	EXEC @NewIDOper=hp_NewPozadavek_TabPrPostup @IDPrikaz=@NewIDPrikaz, @IDTypoveOperace=@IDTypOperace
	UPDATE TabPrPostup SET Plan_ukonceni=@Termin_naceneni WHERE ID=@NewIDOper
	UPDATE TabPrPostup SET
	TAC_T=1,
	TAC_J_T=1,
	TAC_Obsluhy_J_T=1, 
	TAC=CASE WHEN @TypDilce='M' THEN 2 ELSE 5 END,
	TAC_J=CASE WHEN @TypDilce='M' THEN 2 ELSE 5 END,
	TAC_Obsluhy=CASE WHEN @TypDilce='M' THEN 2 ELSE 5 END,
	TAC_Obsluhy_J=CASE WHEN @TypDilce='M' THEN 2 ELSE 5 END
	WHERE ID=@NewIDOper
	END;

	FETCH NEXT FROM CurPolZak INTO @IDZakazky, @TypDilce, @PocetPol;
	END;
CLOSE CurPolZak;
DEALLOCATE CurPolZak;

NOTERMIN:
--finální update, pokud proběhne vše výše
UPDATE TabStrukKusovnik_kalk_cenik SET Termin_naceneni=@Termin_naceneni  WHERE ID IN (SELECT ID FROM #TabTempZak)
END;



GO

