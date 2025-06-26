USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_kontrola_prevodu_z_EP]    Script Date: 26.06.2025 10:50:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_kontrola_prevodu_z_EP]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @RadaDokladu NVARCHAR(3);
DECLARE @RadaDokladu_orig NVARCHAR(3);
DECLARE @DruhPohybu_orig TINYINT;
SET @RadaDokladu=(SELECT RadaDokladu FROM #TempDefForm_Validace);
SET @RadaDokladu_orig=(SELECT TOP 1 s.RadaDokladu
						FROM TabPohybyZbozi z
						LEFT OUTER JOIN TabDokladyZbozi dz ON dz.ID=z.IDDoklad
						JOIN #TempDefForm_Validace ON #TempDefForm_Validace.ID=dz.ID
						LEFT JOIN TabPohybyZbozi r ON r.ID=z.IDOldPolozka
						LEFT JOIN TabDokladyZbozi s ON s.ID=r.IDDoklad
						WHERE s.PoradoveCislo IS NOT NULL AND z.IDDoklad=dz.ID AND dz.ID=#TempDefForm_Validace.ID);
SET @DruhPohybu_orig=(SELECT TOP 1 s.DruhPohybuZbo
						FROM TabPohybyZbozi z
						LEFT OUTER JOIN TabDokladyZbozi dz ON dz.ID=z.IDDoklad
						JOIN #TempDefForm_Validace ON #TempDefForm_Validace.ID=dz.ID
						LEFT JOIN TabPohybyZbozi r ON r.ID=z.IDOldPolozka
						LEFT JOIN TabDokladyZbozi s ON s.ID=r.IDDoklad
						WHERE s.PoradoveCislo IS NOT NULL AND z.IDDoklad=dz.ID AND dz.ID=#TempDefForm_Validace.ID);
IF EXISTS (SELECT * FROM #TempDefFormInfo WHERE BrowseID=18)
BEGIN
IF (@RadaDokladu='656' AND @RadaDokladu_orig='474' AND @DruhPohybu_orig=9)
BEGIN
  RAISERROR(N'Nelze uložit výdejku řady 656 vytvořenou převodem z EP řady 474!', 16, 1)
  RETURN
END
END;
GO

