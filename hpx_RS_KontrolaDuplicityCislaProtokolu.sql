USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KontrolaDuplicityCislaProtokolu]    Script Date: 26.06.2025 14:13:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KontrolaDuplicityCislaProtokolu]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @IDProt INT;
DECLARE @CisloMaj INT;
DECLARE @TypMaj NCHAR(3);
SET @IDProt=(SELECT ID FROM #TempDefForm_Validace)
SET @CisloMaj=(SELECT CisloMaj FROM #TempDefForm_Validace)
SET @TypMaj=(SELECT TypMaj FROM #TempDefForm_Validace)

IF EXISTS(SELECT*
			FROM #TempDefForm_Validace 
			JOIN TabMaPrZa pz ON pz.CisloMaj=#TempDefForm_Validace.CisloMaj AND pz.TypMaj=#TempDefForm_Validace.TypMaj
			WHERE #TempDefForm_Validace.ID <> pz.ID AND pz.TypMaj=#TempDefForm_Validace.TypMaj AND pz.CisloMaj=#TempDefForm_Validace.CisloMaj)
				
BEGIN
  SELECT 2, N'Existuje jiný protokol se stejným číslem, chcete přesto uložit?', N'CisloMaj'
  RETURN
END

GO

