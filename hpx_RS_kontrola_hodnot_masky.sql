USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_kontrola_hodnot_masky]    Script Date: 26.06.2025 12:37:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_kontrola_hodnot_masky]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS

-- ohlášení chyby s nastavením fokusu na odpovídající políčko
IF EXISTS(SELECT*FROM #TempDefForm_Validace WHERE lci_gen_atr_Sloupec4 < 0)
BEGIN
  SELECT 1, N'Obchodní přirážka musí být větší než 0.', N'lci_gen_atr_Sloupec4'
  RETURN
END
GO

