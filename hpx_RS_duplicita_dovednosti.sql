USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_duplicita_dovednosti]    Script Date: 26.06.2025 12:36:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_duplicita_dovednosti]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @IDDov INT;
DECLARE @Nazev NVARCHAR(255);
SET @IDDov=(SELECT ID FROM #TempDefForm_Validace)
SET @Nazev=(SELECT Nazev FROM #TempDefForm_Validace)
IF EXISTS(SELECT*
			FROM #TempDefForm_Validace 
			JOIN TabPersZnalostiCis dov ON dov.Nazev=#TempDefForm_Validace.Nazev
			WHERE #TempDefForm_Validace.ID <> dov.ID AND dov.Nazev=#TempDefForm_Validace.Nazev)
BEGIN
  SELECT 1, N'Duplicita názvu dovednosti, nelze uložit!', N'Nazev'
  RETURN
END
GO

