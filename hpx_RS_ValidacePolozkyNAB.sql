USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ValidacePolozkyNAB]    Script Date: 30.06.2025 8:58:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ValidacePolozkyNAB]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS

IF EXISTS(SELECT*FROM #TempDefForm_Validace)
BEGIN
DECLARE @IDPol INT;
SET @IDPol=(SELECT ID FROM #TempDefForm_Validace)
EXEC dbo.hpx_RS_PrepocetSlevNakup @IDPol
END
GO

