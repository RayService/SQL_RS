USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_SchvalovaciRizeniTPV]    Script Date: 30.06.2025 8:47:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_SchvalovaciRizeniTPV]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @RadaZmeny NVARCHAR(10)
DECLARE @IDPrikaz INT
SET @RadaZmeny=(SELECT tcz.Rada
FROM #TempDefForm_Validace val
LEFT OUTER JOIN TabSchvalRizeni tschr ON tschr.ID=val.ID
LEFT OUTER JOIN TabCzmeny tcz ON tcz.ID=tschr.IDVazby AND tschr.TypVazby=2)
SET @IDPrikaz=(SELECT _EXT_RS_VyrPrikaz FROM #TempDefForm_Validace_EXT)

IF @IDPrikaz IS NULL AND @RadaZmeny IN ('C zákazník','C boom')
BEGIN
  SELECT 1, N'Není vyplněn výrobní příkaz na Přezkoumání změny', N'_EXT_RS_VyrPrikaz'
  RETURN
END




GO

