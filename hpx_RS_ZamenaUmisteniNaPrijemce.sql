USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZamenaUmisteniNaPrijemce]    Script Date: 26.06.2025 14:25:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZamenaUmisteniNaPrijemce]
@IDVydej INT
AS
DECLARE @IDStorno INT--, @IDvydej INT
DECLARE @IDSkladPrijem NVARCHAR(30)

IF OBJECT_ID('tempdb..#Umisteni') IS NOT NULL DROP TABLE #Umisteni
CREATE TABLE #Umisteni (ID INT IDENTITY(1,1) NOT NULL,IDStavSkladu INT,IDKmenZbozi INT,IDVyrCis INT,IDUmisteni INT,DruhPohybu INT,Mnozstvi NUMERIC(19, 6),IDPohZbo INT,NazevVyrC NVARCHAR(100), Kod NVARCHAR(100))

--SET @IDvydej=1774124
SET @IDStorno=(
SELECT DISTINCT tdzP.ID
FROM TabDokladyZbozi tdzV
LEFT OUTER JOIN TabPohybyZbozi tpzP ON tpzP.IDOldDoklad=tdzV.ID
LEFT OUTER JOIN TabDokladyZbozi tdzP ON tpzP.IDDoklad=tdzP.ID
WHERE tdzv.ID=@IDvydej)
--SET @IDStorno=1763187

IF @IDStorno IS NULL
BEGIN
RAISERROR('Nenalezena převodní příjemka, aktualizace neproběhne.',16,1)
RETURN
END;

SET @IDSkladPrijem=(SELECT IDSklad FROM TabDokladyZbozi tdz WHERE tdz.ID=@IDStorno)

SELECT gpu.ID,gpu.IDStavSkladu,gpu.IDKmenZbozi,gpu.IDVyrCis,gpu.IDUmisteni,gpu.DruhPohybu,gpu.Mnozstvi,gpu.IDPohZbo,vcs.Nazev1,tu.Kod
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN Gatema_PohybUmisteni gpu ON gpu.IDPohZbo=tpz.ID
LEFT OUTER JOIN TabUmisteni tu ON tu.ID=gpu.IDUmisteni
LEFT OUTER JOIN TabVyrCS vcs ON vcs.ID=gpu.IDVyrCis
WHERE tpz.IDDoklad=@IDvydej
ORDER BY vcs.Nazev1 ASC

INSERT INTO #Umisteni (IDStavSkladu,IDKmenZbozi,IDVyrCis,DruhPohybu,Mnozstvi,IDPohZbo,NazevVyrC)
SELECT tpz.IDZboSklad,tss.IDKmenZbozi, vcp.IDVyrCis,0,vcp.Mnozstvi,tpz.ID,vcs.Nazev1
FROM TabVyrCP vcp
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcs.ID=vcp.IDVyrCis
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.ID=tpz.IDZboSklad AND tss.IDSklad=@IDSkladPrijem
WHERE tpz.IDDoklad=@IDStorno


;WITH CTE AS (SELECT tu.Kod, vcs.Nazev1, gpu.Mnozstvi
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN Gatema_PohybUmisteni gpu ON gpu.IDPohZbo=tpz.ID
LEFT OUTER JOIN TabUmisteni tu ON tu.ID=gpu.IDUmisteni
LEFT OUTER JOIN TabVyrCS vcs ON vcs.ID=gpu.IDVyrCis
WHERE tpz.IDDoklad=@IDvydej)
UPDATE umn SET umn.Kod=CTE.Kod
FROM #Umisteni umn
LEFT OUTER JOIN CTE ON CTE.Nazev1=umn.NazevVyrC AND CTE.Mnozstvi*(-1)=umn.Mnozstvi

UPDATE umn SET umn.IDUmisteni=tu.ID
FROM #Umisteni umn
LEFT OUTER JOIN TabUmisteni tu ON tu.Kod=umn.Kod AND tu.IdSklad=@IDSkladPrijem

	--pokud umístění na skladu 115 chybí, dogenerovat
	IF EXISTS (SELECT * FROM #Umisteni WHERE IDUmisteni IS NULL)
	BEGIN
		IF OBJECT_ID('tempdb..#UmisteniNew') IS NOT NULL DROP TABLE #UmisteniNew
		CREATE TABLE #UmisteniNew (ID INT IDENTITY(1,1) NOT NULL, IDUmisteni INT, Kod NVARCHAR(100), IDSklad NVARCHAR(30), _IDPolice INT, _PovolitZaporneMnozNaUmisteni BIT, _VyjmoutZMapySkladu BIT, _EXT_RS_IDLocationPrint INT, _EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint BIT,  _EXT_RS_generate_stock_taking_subordinate BIT, _EXT_RS_PhysicalPlace INT)

		DECLARE @IDSkladVydej NVARCHAR(30)
		DECLARE @U TABLE (ID INT)
		SET @IDSkladVydej=(SELECT IDSklad FROM TabDokladyZbozi WHERE ID=@IDVydej)
		;WITH InsU AS (SELECT u.Kod AS Kod, @IDSkladPrijem AS IDSklad, tu.Nazev AS Nazev--, tue._IDPolice, tue._PovolitZaporneMnozNaUmisteni, tue._VyjmoutZMapySkladu , tue._EXT_RS_IDLocationPrint, tue._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint, tue._EXT_RS_generate_stock_taking_subordinate, tue._EXT_RS_PhysicalPlace
		FROM #Umisteni u
		LEFT OUTER JOIN TabUmisteni tu ON tu.Kod=u.Kod AND tu.IDSklad=@IDSkladVydej
		WHERE u.IDUmisteni IS NULL)
		INSERT INTO TabUmisteni (Kod, IDsklad, Nazev)
		OUTPUT inserted.ID INTO @U
		SELECT InsU.Kod, InsU.IDSklad, InsU.Nazev
		FROM InsU

		INSERT INTO #UmisteniNew (IDUmisteni)
		SELECT ID FROM @U

		UPDATE un SET un.Kod=tu.Kod, un.IDSklad=tu.IdSklad
		FROM #UmisteniNew un
		LEFT OUTER JOIN TabUmisteni tu ON tu.ID=un.IDUmisteni
		WHERE tu.IdSklad=@IDSkladPrijem

		UPDATE un SET un._IDPolice=tue._IDPolice, un._PovolitZaporneMnozNaUmisteni=tue._PovolitZaporneMnozNaUmisteni,un._VyjmoutZMapySkladu=tue._VyjmoutZMapySkladu , un._EXT_RS_IDLocationPrint=tue._EXT_RS_IDLocationPrint,
		un._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint=tue._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint, un._EXT_RS_generate_stock_taking_subordinate=tue._EXT_RS_generate_stock_taking_subordinate, un._EXT_RS_PhysicalPlace=tue._EXT_RS_PhysicalPlace
		FROM #UmisteniNew un
		LEFT OUTER JOIN TabUmisteni tu100 ON tu100.Kod=un.Kod AND tu100.IDSklad=@IDSkladVydej
		LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=tu100.ID

		--SELECT * FROM #UmisteniNew

		MERGE TabUmisteni_EXT AS TARGET
		USING #UmisteniNew AS SOURCE
		ON TARGET.ID=SOURCE.IDUmisteni
		WHEN MATCHED THEN UPDATE SET
		TARGET._IDPolice=SOURCE._IDPolice, TARGET._PovolitZaporneMnozNaUmisteni=SOURCE._PovolitZaporneMnozNaUmisteni,TARGET._VyjmoutZMapySkladu=SOURCE._VyjmoutZMapySkladu , TARGET._EXT_RS_IDLocationPrint=SOURCE._EXT_RS_IDLocationPrint,
		TARGET._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint=SOURCE._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint, TARGET._EXT_RS_generate_stock_taking_subordinate=SOURCE._EXT_RS_generate_stock_taking_subordinate,
		TARGET._EXT_RS_PhysicalPlace=SOURCE._EXT_RS_PhysicalPlace
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (ID,_IDPolice, _PovolitZaporneMnozNaUmisteni,_VyjmoutZMapySkladu , _EXT_RS_IDLocationPrint, _EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint, _EXT_RS_generate_stock_taking_subordinate, _EXT_RS_PhysicalPlace)
		VALUES (SOURCE.IDUmisteni, SOURCE._IDPolice, SOURCE._PovolitZaporneMnozNaUmisteni, SOURCE._VyjmoutZMapySkladu , SOURCE._EXT_RS_IDLocationPrint,SOURCE._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint,
		SOURCE._EXT_RS_generate_stock_taking_subordinate, SOURCE._EXT_RS_PhysicalPlace)
		;
	END;



UPDATE umn SET umn.IDUmisteni=tu.ID
FROM #Umisteni umn
LEFT OUTER JOIN TabUmisteni tu ON tu.Kod=umn.Kod AND tu.IdSklad=@IDSkladPrijem

SELECT * FROM #Umisteni ORDER BY NazevVyrC ASC


DELETE FROM gpu
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN Gatema_PohybUmisteni gpu ON gpu.IDPohZbo=tpz.ID
LEFT OUTER JOIN TabUmisteni tu ON tu.ID=gpu.IDUmisteni
LEFT OUTER JOIN TabVyrCS vcs ON vcs.ID=gpu.IDVyrCis
WHERE tpz.IDDoklad=@IDStorno

INSERT INTO Gatema_PohybUmisteni (IDStavSkladu,IDKmenZbozi,IDVyrCis,IDUmisteni,DruhPohybu,Mnozstvi,IDPohZbo)
SELECT IDStavSkladu,IDKmenZbozi,IDVyrCis,IDUmisteni,DruhPohybu,Mnozstvi,IDPohZbo
FROM #Umisteni

GO

