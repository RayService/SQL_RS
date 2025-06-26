USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_duplicita_dovednosti_zamestnance]    Script Date: 26.06.2025 12:32:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_duplicita_dovednosti_zamestnance]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
IF EXISTS(SELECT*
			FROM #TempDefForm_Validace 
			JOIN TabCisZamZnalosti zamdov ON zamdov.ZamestnanecId=#TempDefForm_Validace.ZamestnanecId AND zamdov.UrovenId=#TempDefForm_Validace.UrovenId AND zamdov.ZnalostId=#TempDefForm_Validace.ZnalostId
			WHERE #TempDefForm_Validace.ID <> zamdov.ID AND zamdov.ZamestnanecId=#TempDefForm_Validace.ZamestnanecId AND zamdov.UrovenId=#TempDefForm_Validace.UrovenId AND zamdov.ZnalostId=#TempDefForm_Validace.ZnalostId)
BEGIN
  SELECT 1, N'Duplicita kombinace zaměstnanec + dovednost + úroveň, nelze uložit!'
  RETURN
END
GO

