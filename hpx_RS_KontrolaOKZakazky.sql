USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KontrolaOKZakazky]    Script Date: 26.06.2025 16:00:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KontrolaOKZakazky]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
SET NOCOUNT ON;

-- ohlášení chyby s nastavením fokusu na odpovídající políčko
IF EXISTS(SELECT*FROM #TempDefForm_Validace WHERE JmenoACesta NOT LIKE 'H:\RS\%' AND JmenoACesta NOT LIKE '\\Rayserverfs\helios%')
BEGIN
  SELECT 1, N'Soubor musí leže v umístění H:\RS\xxx.', N'JmenoACesta'
  RETURN
END

GO

