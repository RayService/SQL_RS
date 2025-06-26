USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_RamcovaKoObOK]    Script Date: 26.06.2025 16:15:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RS_RamcovaKoObOK]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS

BEGIN
DECLARE @Cislo INT
DECLARE @Rada INT
SET @Rada=(SELECT Rada FROM #TempDefForm_Validace)
SET @Cislo=(SELECT MAX(ISNULL(kob.Cislo,1))+1
FROM Tabx_RS_RamcKoopObj kob
WHERE kob.Rada=@Rada)
IF @Cislo IS NULL
BEGIN
SET @Cislo=1
END;
UPDATE kob SET kob.Cislo=@Cislo
FROM #TempDefForm_Validace val
LEFT OUTER JOIN Tabx_RS_RamcKoopObj kob ON kob.ID=val.ID
WHERE kob.ID=val.ID
END;
GO

