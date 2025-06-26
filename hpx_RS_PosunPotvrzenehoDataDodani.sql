USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PosunPotvrzenehoDataDodani]    Script Date: 26.06.2025 15:46:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PosunPotvrzenehoDataDodani]
AS

SET NOCOUNT ON;
BEGIN
IF OBJECT_ID('tempdb..#Polozky_potvrzene_datum') IS NOT NULL DROP TABLE #Polozky_potvrzene_datum
CREATE TABLE #Polozky_potvrzene_datum (ID INT,IDDoklad INT,ParovaciZnak NVARCHAR(20),PotvrzDatDod DATETIME,_dat_dod1 DATETIME,SkupZbo NVARCHAR(3),RegCis NVARCHAR(30))
INSERT INTO #Polozky_potvrzene_datum (ID,IDDoklad,ParovaciZnak,PotvrzDatDod,_dat_dod1,SkupZbo,RegCis)
SELECT tpz.ID,tpz.IDDoklad,tdz.ParovaciZnak,tpz.PotvrzDatDod,tpze._dat_dod1,tpz.SkupZbo,tpz.RegCis
FROM TabPohybyZbozi tpz WITH(NOLOCK)
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabPohybyZbozi_EXT tpze WITH(NOLOCK) ON tpze.ID=tpz.ID
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
WHERE
(tpz.PotvrzDatDod IS NOT NULL)AND(tdz.DruhPohybuZbo=6)AND(tdz.IDSklad = '100')
AND((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tpz.PotvrzDatDod_X<CONVERT(DATE,GETDATE()))
AND(tdz.Splneno<>1)
--AND(tco.CisloOrg IN (4414,807,1990,2154,6545,2678,4916))	--MŽ, 11.10.2024 pouze pro vybrané organizace, 4.11.2024 vypnuta podmínka - nyní běží pro všechny

--MŽ, 9.8.2024 novinka údaje PotvrzDatDod se zapisují před změnou do externí tabule Tabx_RS_PohybyPotvrzDat
INSERT INTO Tabx_RS_PohybyPotvrzDat (IDPohyb, PotvrzDat)
SELECT ID, PotvrzDatDod
FROM #Polozky_potvrzene_datum

--úprava _dat_dod1 a PotvrzDatDod v dočasné tabulce
DECLARE @ID INT;
DECLARE Polozky CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID
	FROM #Polozky_potvrzene_datum
OPEN Polozky;
	FETCH NEXT FROM Polozky INTO @ID;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	-- zacatek akce v kurzoru Polozky
	IF (SELECT #Polozky_potvrzene_datum._dat_dod1 FROM #Polozky_potvrzene_datum WHERE ID=@ID) IS NULL
	BEGIN
	UPDATE #Polozky_potvrzene_datum SET #Polozky_potvrzene_datum._dat_dod1=#Polozky_potvrzene_datum.PotvrzDatDod
	FROM #Polozky_potvrzene_datum
	WHERE #Polozky_potvrzene_datum.ID =@ID
	END
	-- konec akce v kurzoru Polozky
	FETCH NEXT FROM Polozky INTO @ID;
	END;
CLOSE Polozky;
DEALLOCATE Polozky;
END;

--zápis _dat_dod1 a PotvrzDatDod do ostrých dat
--zápis počtu posunů a zároveň do pole Potvrzený termín dodání nedodané položky (nové uživ.pole) se zkopíruje z minimálního data z uživ.tabulky
BEGIN
DECLARE @IDPol INT;
DECLARE @MinDatum DATETIME;
DECLARE Polozky_upd CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID
	FROM #Polozky_potvrzene_datum
OPEN Polozky_upd;
	FETCH NEXT FROM Polozky_upd INTO @IDPol;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	-- zacatek akce v kurzoru Polozky_upd
	--vložení potvrzeného data dodání nedodané položky
	SET @MinDatum=(SELECT MIN(PotvrzDat) FROM Tabx_RS_PohybyPotvrzDat WHERE IDPohyb=@IDPol AND ISNULL(Archive,0)=0)
	BEGIN
	UPDATE tpze SET tpze._EXT_RS_PotvrzTermNedodPolozky=@MinDatum
	FROM TabPohybyZbozi_EXT tpze
	LEFT OUTER JOIN #Polozky_potvrzene_datum WITH(NOLOCK) ON #Polozky_potvrzene_datum.ID=tpze.ID
	WHERE tpze.ID =@IDPol
	END;
	--zápis počtu posunů
	BEGIN
	UPDATE tpze SET tpze._EXT_RS_MovNumber=ISNULL(_EXT_RS_MovNumber,0)+1
	FROM TabPohybyZbozi_EXT tpze
	LEFT OUTER JOIN #Polozky_potvrzene_datum WITH(NOLOCK) ON #Polozky_potvrzene_datum.ID=tpze.ID
	WHERE tpze.ID =@IDPol
	END;
	BEGIN
	UPDATE tpze SET tpze._dat_dod1=#Polozky_potvrzene_datum._dat_dod1--, tpze._EXT_RS_PotvrzTermNedodPolozky=#Polozky_potvrzene_datum.PotvrzDatDod
	FROM TabPohybyZbozi_EXT tpze
	LEFT OUTER JOIN #Polozky_potvrzene_datum WITH(NOLOCK) ON #Polozky_potvrzene_datum.ID=tpze.ID
	WHERE tpze.ID =@IDPol
	END;
	BEGIN
	UPDATE tpz SET tpz.PotvrzDatDod=#Polozky_potvrzene_datum.PotvrzDatDod+14	--změna oproti původnímu =NULL
	FROM TabPohybyZbozi tpz
	LEFT OUTER JOIN #Polozky_potvrzene_datum WITH(NOLOCK) ON #Polozky_potvrzene_datum.ID=tpz.ID
	WHERE tpz.ID =@IDPol
	END;
	-- konec akce v kurzoru Polozky_upd
	FETCH NEXT FROM Polozky_upd INTO @IDPol;
	END;
CLOSE Polozky_upd;
DEALLOCATE Polozky_upd;
END;



GO

