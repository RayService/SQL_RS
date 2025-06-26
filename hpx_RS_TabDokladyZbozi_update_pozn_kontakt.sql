USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_TabDokladyZbozi_update_pozn_kontakt]    Script Date: 26.06.2025 12:38:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_TabDokladyZbozi_update_pozn_kontakt] @ID INT
AS
BEGIN
DECLARE @Pocet INT
DECLARE @IDOldPolozka INT
DECLARE @IDOldDoklad INT
DECLARE @IDPol INT
DECLARE @OldPozn NVARCHAR(MAX)
DECLARE @OldKontaktOsoba INT
--cvičně deklaruju ID dokladu
-- Vytvoření tabulky #Polozky a vložení položek z hlavičky dokladu @ID 
SELECT TabPohybyZbozi.* INTO #Polozky FROM TabPohybyZbozi WHERE TabPohybyZbozi.IDDoklad = @ID
SELECT * FROM #Polozky
BEGIN
	SET @IDPol = (SELECT TOP 1 ID FROM #Polozky)
	SET @IDOldPolozka = (SELECT IDOldPolozka FROM #Polozky WHERE ID = @IDPol)
	SET @IDOldDoklad = (SELECT IDDoklad FROM TabPohybyZbozi WHERE ID = @IDOldPolozka)
	SET @OldPozn = (SELECT Poznamka FROM TabDokladyZbozi WHERE ID = @IDOldDoklad)
	SET @OldKontaktOsoba = (SELECT KontaktOsoba FROM TabDokladyZbozi WHERE ID = @IDOldDoklad)
SELECT @OldKontaktOsoba
SELECT @OldPozn
UPDATE TabDokladyZbozi SET KontaktOsoba = @OldKontaktOsoba, Poznamka = @OldPozn +';
;'+ CAST(Poznamka AS NVARCHAR(MAX))
FROM TabDokladyZbozi
WHERE ID = @ID
END
DROP TABLE #Polozky
END

BEGIN
DECLARE @IDDoklad INT=@ID
DECLARE @ZDokladu BIT = 0;	-- volání z dokladu 1-Ano,0-ne
DECLARE @OznaceniPolozky NVARCHAR(255);
DECLARE @MnoRozhodne NUMERIC(19,6);
DECLARE @IDPolNew INT--=5842107;
/*
IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
BEGIN
DROP TABLE #TabExtKom
END;*/
--CREATE TABLE #TabExtKom (ID INT IDENTITY(1,1), Poznamka NVARCHAR(255))
--započneme cursor
DECLARE CurPolProb CURSOR LOCAL FAST_FORWARD FOR
SELECT tpz.ID
FROM TabPohybyZbozi tpz
WHERE tpz.IDDoklad=@IDDoklad

OPEN CurPolProb;
	FETCH NEXT FROM CurPolProb INTO @IDPolNew;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	--množství po příjmu
	SET @MnoRozhodne=(SELECT tss.MnozSPrij AS MnoPoPrijmu
	FROM TabPohybyZbozi tpz WITH(NOLOCK)
	LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tpz.IDZboSklad=tss.ID
	LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT tsk.IDKmenZbozi FROM TabStavSkladu tsk WHERE tsk.ID=tpz.IDZboSklad)
	WHERE tpz.ID=@IDPolNew
	GROUP BY tkz.ID, tss.MnozSPrij)
	- --množství na výr.plánu
	(SELECT ISNULL(SUM(tppkv.mnoz_zad),0) AS MnoPlan--zbývá zaplánovat
	FROM TabPohybyZbozi tpz WITH(NOLOCK)
	LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tsk.IDKmenZbozi FROM TabStavSkladu tsk WHERE tsk.ID=tpz.IDZboSklad)
	LEFT OUTER JOIN TabPlanPrKVazby tppkv WITH(NOLOCK) ON tppkv.nizsi = tkz.ID
	LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID = tppkv.IDPlan
	LEFT OUTER JOIN TabRadyPlanu trp WITH(NOLOCK) ON trp.Rada = tp.Rada
	LEFT OUTER JOIN TabPlanPrikaz tplpr WITH(NOLOCK) ON tplpr.ID=tppkv.IDPlanPrikaz
	WHERE tpz.ID=@IDPolNew AND trp.ZahrnoutDoBilancovaniBudPoh = 2 AND (tplpr.Plan_zadani>=GETDATE() AND tplpr.Plan_zadani<=GETDATE()+112))
	- --množství zbývá vydat na VP
	(SELECT ISNULL(SUM(T.MnoVP),0)-ISNULL(SUM(T.MnoGen),0)
	FROM (SELECT prkv.mnoz_pozadovane AS MnoVP,
	(SELECT ISNULL(SUM(CASE WHEN PZ.druhPohybuZbo=3 THEN -1.0 ELSE 1.0 END * PZ.prepmnozstvi*(PZ.Mnozstvi-PZ.MnOdebrane)), 0.0)
	FROM TabPohybyZbozi PZ INNER JOIN TabStavSkladu SS ON (SS.ID=PZ.IDZboSklad) INNER JOIN TabDokladyZbozi DZ ON (DZ.ID=PZ.IDDoklad AND DZ.splneno=0)
	WHERE PZ.druhPohybuZbo IN (2,3,4,9,10) AND PZ.Splneno=0 AND PZ.TypVyrobnihoDokladu=1 AND PZ.IDPrikaz=prkv.IDPrikaz AND PZ.DokladPrikazu=prkv.Doklad AND SS.IDKmenZbozi=prkv.nizsi) AS MnoGen
	FROM TabPohybyZbozi tpz WITH(NOLOCK)
	LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT tsk.IDKmenZbozi FROM TabStavSkladu tsk WHERE tsk.ID=tpz.IDZboSklad)
	LEFT OUTER JOIN TabPrKVazby prkv WITH(NOLOCK) ON prkv.nizsi=tkz.ID
	LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON prkv.IDPrikaz=tp.ID
	WHERE ((tpz.ID=@IDPolNew)AND(prkv.IDOdchylkyDo IS NULL)AND(prkv.prednastaveno=1)AND(prkv.mnoz_Nevydane<>0)AND(tp.StavPrikazu=30)))
	AS T)

	IF @MnoRozhodne<0
	BEGIN
	SET @OznaceniPolozky=(SELECT tpz.SkupZbo+'/'+tpz.RegCis+' - '+tpz.Nazev1 FROM TabPohybyZbozi tpz WHERE tpz.ID=@IDPolNew)


		-- hláška uživateli - spouštěno z akce
		IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
			AND NOT @ZDokladu = 1
				BEGIN
					INSERT INTO #TabExtKom(Typ,Poznamka)
					VALUES(2,'Položka '+@OznaceniPolozky + ' je problematická');
				END;
	END;
	
	-- konec akce v kurzoru CurPolProb
FETCH NEXT FROM CurPolProb INTO @IDPolNew;
END;
CLOSE CurPolProb;
DEALLOCATE CurPolProb;
END;
GO

