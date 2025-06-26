USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zapis_evidence_personalistika]    Script Date: 26.06.2025 10:49:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zapis_evidence_personalistika] @IDevidence INT
AS
--DECLARE @IDevidence INT--=2144535
DECLARE @IDSkoliciAkceH INT--=1688
DECLARE @DatumOd DATETIME
DECLARE @DatumDo DATETIME
DECLARE @CisZamOper INT
SET @IDSkoliciAkceH=(SELECT TOP 1 _EXT_RS_ID_training FROM TabPrikazMzdyAZmetky tpmaz
					JOIN TabPrikazMzdyAZmetky_EXT tpmaze ON tpmaze.ID=tpmaz.ID
					WHERE tpmaz.ID=@IDevidence)
SET @DatumOd=(SELECT tsaH.DatumOd FROM TabSkoliciAkceH tsaH WHERE tsaH.ID= @IDSkoliciAkceH)
--SET @DatumDo=(SELECT DatumDo FROM TabSkoliciAkceH tsaH WHERE tsaH.ID= @IDSkoliciAkceH)
SET @CisZamOper=(SELECT tcz.Cislo FROM TabPrikazMzdyAZmetky tpmaz
LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=tpmaz.Zamestnanec
					WHERE tpmaz.ID=@IDevidence)
--SELECT @IDSkoliciAkceH
BEGIN
IF OBJECT_ID('tempdb..#Skoleni') IS NOT NULL DROP TABLE #Skoleni
CREATE TABLE #Skoleni (ID INT IDENTITY(1,1),Evidence NUMERIC(19,2), Cislo INT, ID_training INT)
INSERT INTO #Skoleni (Evidence,Cislo,ID_training)
SELECT SUM(tpmaz.kusy_odv),tcz.Cislo,tpmaze._EXT_RS_ID_training
FROM TabPrikazMzdyAZmetky tpmaz WITH(NOLOCK)
LEFT OUTER JOIN TabPrikazMzdyAZmetky_EXT tpmaze WITH(NOLOCK) ON tpmaze.ID=tpmaz.ID
LEFT OUTER JOIN TabCisZam tcz WITH(NOLOCK) ON tcz.ID=tpmaz.Zamestnanec
WHERE tpmaze._EXT_RS_ID_training=@IDSkoliciAkceH AND tpmaz.Stav=1
GROUP BY tcz.Cislo,tpmaze._EXT_RS_ID_training

--nejprve zapíšeme do hlavičky školící akce, že proběhla
IF (SELECT SUM(Evidence) FROM #Skoleni) > 0
BEGIN
UPDATE TabSkoliciAkceH SET StavAkce=2, DatumDo = @DatumOd, DatZmeny = GETDATE() WHERE ID=@IDSkoliciAkceH
END
--zápis do účastníků školící akce, že se zúčastnili
DECLARE @ID INT;
DECLARE Skoleni CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID
	FROM #Skoleni
OPEN Skoleni;
	FETCH NEXT FROM Skoleni INTO @ID;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
	-- zacatek akce v kurzoru Skoleni
	IF (SELECT SUM(Evidence) FROM #Skoleni WHERE Cislo=@CisZamOper) >= 1
	BEGIN
	UPDATE tsaR SET Ucasten=1
	FROM TabSkoliciAkceR tsaR
	LEFT OUTER JOIN TabSkoliciAkceR_EXT tsaRe ON tsarE.ID=tsar.ID
	--LEFT OUTER JOIN #Skoleni ON #Skoleni.Cislo=tsaR.CisloZam AND #Skoleni.ID_training=tsaR.IDHlava
	WHERE tsaR.IDHlava=@IDSkoliciAkceH AND tsar.CisloZam=@CisZamOper--#Skoleni.Cislo AND #Skoleni.ID=@ID
	END

              IF (SELECT SUM(Evidence) FROM #Skoleni WHERE Cislo=@CisZamOper)=0
	BEGIN
                IF (SELECT tsaRe.ID FROM TabSkoliciAkceR_EXT tsaRe
                LEFT OUTER JOIN TabSkoliciAkceR tsaR ON tsarE.ID=tsar.ID 
                WHERE tsaR.IDHlava=@IDSkoliciAkceH AND tsar.CisloZam=@CisZamOper) IS NULL
                      BEGIN
                           INSERT INTO TabSkoliciAkceR_EXT (ID,_EXT_RS_neprosel) 
                           SELECT tsaR.ID,1
                           FROM TabSkoliciAkceR tsaR
                           WHERE tsaR.IDHlava=@IDSkoliciAkceH AND tsar.CisloZam=@CisZamOper
                      END
              ELSE
	UPDATE tsaRe SET _EXT_RS_neprosel=1
	FROM TabSkoliciAkceR tsaR
	LEFT OUTER JOIN TabSkoliciAkceR_EXT tsaRe ON tsarE.ID=tsar.ID
	WHERE tsaR.IDHlava=@IDSkoliciAkceH AND tsar.CisloZam=@CisZamOper--#Skoleni.Cislo AND #Skoleni.ID=@ID
	END
	-- konec akce v kurzoru Skoleni
	FETCH NEXT FROM Skoleni INTO @ID;
	END;
CLOSE Skoleni;
DEALLOCATE Skoleni;
END;
GO

