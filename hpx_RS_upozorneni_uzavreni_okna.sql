USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_upozorneni_uzavreni_okna]    Script Date: 26.06.2025 11:03:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_upozorneni_uzavreni_okna]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
-- Informační hláška
IF EXISTS(SELECT*FROM #TempDefForm_Validace)
BEGIN
  SELECT 2, N'Fakt chceš zavřít toto okno?????'
  RETURN
END
GO

