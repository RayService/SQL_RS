USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PrenosPozadIndexuDoNab]    Script Date: 26.06.2025 14:14:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PrenosPozadIndexuDoNab]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @RadaDokladu_orig NVARCHAR(3);
DECLARE @Index NVARCHAR(15);
DECLARE @IDOrig NVARCHAR(15);
SET @RadaDokladu_orig=(SELECT TOP 1 s.RadaDokladu
						FROM TabPohybyZbozi tpz
						LEFT OUTER JOIN #TempDefForm_Validace ON #TempDefForm_Validace.ID=tpz.ID
						LEFT JOIN TabPohybyZbozi r ON r.ID=tpz.IDOldPolozka
						LEFT JOIN TabDokladyZbozi s ON s.ID=r.IDDoklad
						WHERE s.PoradoveCislo IS NOT NULL AND tpz.ID=#TempDefForm_Validace.ID);
SET @IDOrig=(SELECT re.ID
						FROM TabPohybyZbozi tpz
						LEFT OUTER JOIN #TempDefForm_Validace ON #TempDefForm_Validace.ID=tpz.ID
						LEFT JOIN TabPohybyZbozi r ON r.ID=tpz.IDOldPolozka
						LEFT JOIN TabPohybyZbozi_EXT re ON re.ID=r.ID
						WHERE tpz.ID=#TempDefForm_Validace.ID);
SET @Index=(SELECT _PozadovanyIndexZmeny FROM #TempDefForm_Validace_EXT);
IF EXISTS (SELECT * FROM #TempDefFormInfo WHERE BrowseID=45)
BEGIN
IF (@RadaDokladu_orig=N'383' OR @RadaDokladu_orig=N'384')
BEGIN
--zapsat požadovaný index do původní položky 
UPDATE tpze SET tpze._PozadovanyIndexZmeny=@Index
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
WHERE tpz.ID=@IDOrig
END;
END;


--_PozadovanyIndexZmeny
GO

