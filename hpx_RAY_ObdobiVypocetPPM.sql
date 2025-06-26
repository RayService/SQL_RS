USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_ObdobiVypocetPPM]    Script Date: 26.06.2025 9:50:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RAY_ObdobiVypocetPPM]  @DatOd DATETIME,   @DatDo DATETIME
AS
-- ==============================================================
-- Author:			josef.cabadaj
-- Create date:		2.5.2011
-- Akce:			EX002315 
-- Name:			Úprava EA - ppm pro organizace -  nového zadání
-- Description:		
-- ==============================================================
---------------------------------------generovaní řádků externí tabulky--------------------------------------
INSERT INTO TabCisOrg_EXT (ID)
SELECT CO.ID FROM TabCisOrg CO WHERE CO.ID NOT IN (SELECT TabCisOrg_EXT.ID FROM TabCisOrg_EXT) 

---------------------------------------deklarace proměných--------------------------------------------------
DECLARE @ID INT
DECLARE @CisloOrg INT
DECLARE @PuvodniOrganizace INT
---------------------------------------vlastni telo procedury-----------------------------------------------
--zadani obdobi do tabulky
UPDATE RAY_RozmDatumuPPM_JOC
SET DatumOd = ISNULL(@DatOd, '20090101') , DatumDo=ISNULL(@DatDo, GETDATE())

DECLARE JOC1_cur CURSOR LOCAL FAST_FORWARD FOR
SELECT CO.ID, CO.CisloOrg, COE._RAY_PuvodOrg_JOC  FROM TabCisOrg CO LEFT JOIN TabCisOrg_EXT COE ON COE.ID=CO.ID WHERE CO.JeOdberatel=1 ORDER BY CO.ID ASC 
OPEN JOC1_cur
        FETCH NEXT FROM JOC1_cur INTO  @ID, @CisloOrg, @PuvodniOrganizace
        WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
		-- zacatek akce v kurzoru
             IF @PuvodniOrganizace IS NULL
                BEGIN
                   UPDATE TabCisOrg_EXT
                   SET _RAY_PPMZa12MVyr_JOC=(CASE 
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365)/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) IS NOT NULL THEN CAST((SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365)/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) AS INT)
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365)/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) IS NULL AND (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365) IS NOT NULL THEN -1

							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365)/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) IS NULL AND (SELECT SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) IS NOT NULL THEN 0
							END)
					WHERE ID= @ID	
					
				   UPDATE TabCisOrg_EXT
                   SET _RAY_PPMZa12MZb_JOC=(CASE
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND DZ.DatPorizeni > GETDATE()-365)  <> 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) <> 0 THEN CAST(((SELECT CAST(count(*) AS NUMERIC (19,6)) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND DZ.DatPorizeni > GETDATE()-365) / (SELECT CAST(count(*) AS NUMERIC (19,6))
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365))*1000000 AS INT)
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND DZ.DatPorizeni > GETDATE()-365)  <> 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) = 0 THEN  -1
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND DZ.DatPorizeni > GETDATE()-365)  = 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) <> 0 THEN 0
							END)
					WHERE ID= @ID
					
									   UPDATE TabCisOrg_EXT
                   SET _RAY_PPMZaObdZbo_JOC=(CASE
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))  <> 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) <> 0 THEN  CAST(((SELECT CAST(count(*) AS NUMERIC (19,6)) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) / (SELECT CAST(count(*) AS NUMERIC (19,6))
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))))*1000000 AS INT)
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))  <> 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) = 0 THEN -1
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))  = 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) <> 0 THEN 0
							END)
					WHERE ID= @ID
					
				   UPDATE TabCisOrg_EXT
                   SET _RAY_PPMZaObdVyr_JOC=(CASE 
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NOT NULL THEN CAST((SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) AS INT ) 
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NULL AND (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NOT NULL THEN -1
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE DZ.CisloOrg =@CisloOrg  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NULL AND (SELECT SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE DZ.CisloOrg =@CisloOrg  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NOT NULL THEN 0
							END)
					WHERE ID= @ID											
                END
              ELSE  
                BEGIN
                   UPDATE TabCisOrg_EXT
                   SET _RAY_PPMZa12MVyr_JOC=(CASE 
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace) AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365)/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) IS NOT NULL THEN  CAST((SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365)/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) AS INT ) 
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365)/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) IS NULL AND (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365) IS NOT NULL THEN -1

							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND DZ.DatPorizeni > GETDATE()-365)/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) IS NULL AND (SELECT SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) IS NOT NULL THEN  0
							END)
					WHERE ID= @ID	
					
				   UPDATE TabCisOrg_EXT
                   SET _RAY_PPMZa12MZb_JOC=(CASE
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND DZ.DatPorizeni > GETDATE()-365)  <> 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) <> 0 THEN  CAST(((SELECT CAST(count(*) AS NUMERIC (19,6)) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND DZ.DatPorizeni > GETDATE()-365) / (SELECT CAST(count(*) AS NUMERIC (19,6))
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365))*1000000 AS INT)
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND DZ.DatPorizeni > GETDATE()-365)  <> 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) = 0 THEN -1
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND DZ.DatPorizeni > GETDATE()-365)  = 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND DZ.DatPorizeni > GETDATE()-365) <> 0 THEN 0
							END)
					WHERE ID= @ID
					
									   UPDATE TabCisOrg_EXT
                   SET _RAY_PPMZaObdZbo_JOC=(CASE
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))  <> 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) <> 0 THEN  CAST(((SELECT CAST(count(*) AS NUMERIC (19,6)) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace) AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) / (SELECT CAST(count(*) AS NUMERIC (19,6))
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))))*1000000 AS INT) 
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))  <> 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) = 0 THEN -1
							WHEN (SELECT count(*) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('001','010','2')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))  = 0   AND (SELECT count(*)
							FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo BETWEEN '100' AND '650' AND DZ.RadaDokladu IN (600,601,602) AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN (2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) <> 0 THEN 0
							END)
					WHERE ID= @ID
					
				   UPDATE TabCisOrg_EXT
                   SET _RAY_PPMZaObdVyr_JOC=(CASE 
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NOT NULL THEN  CAST((SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) AS INT )
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NULL AND (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O' AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NOT NULL THEN -1
							WHEN (SELECT (SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad LEFT JOIN TabZakazka Z ON DZ.CisloZakazky =Z.CisloZakazky
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND DZ.RadaDokladu IN ('910')  AND DZ.DruhPohybuZbo = 11 AND PZ.NazevSozNa1 LIKE 'O'AND Z.Identifikator IN ('020','050')AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)))/SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace) AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NULL AND (SELECT SUM(PZ.Mnozstvi)*1000000  FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ ON DZ.ID =PZ.IDDoklad 
							WHERE (DZ.CisloOrg =@CisloOrg OR DZ.CisloOrg = @PuvodniOrganizace)  AND PZ.SkupZbo IN ('800', '850') AND DZ.RadaDokladu IN ('655','656','657') AND DZ.Realizovano= 1 AND DZ.DruhPohybuZbo IN ( 2, 3, 4)  AND (DZ.DatPorizeni >= (SELECT DatumOd FROM RAY_RozmDatumuPPM_JOC WHERE ID =1)AND DZ.DatPorizeni <=(SELECT DatumDo FROM RAY_RozmDatumuPPM_JOC WHERE ID =1))) IS NOT NULL THEN  0
							END)
					WHERE ID= @ID											
                END                                         
		-- konec akce v kurzoru
        FETCH NEXT FROM JOC1_cur INTO  @ID, @CisloOrg, @PuvodniOrganizace
        END
CLOSE JOC1_cur
DEALLOCATE JOC1_cur
GO

