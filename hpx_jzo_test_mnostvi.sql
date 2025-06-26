USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_jzo_test_mnostvi]    Script Date: 26.06.2025 12:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_jzo_test_mnostvi]
@ValidaceOK BIT, -- 1 = tlačítko OK, 0 = tlačítko Storno
@NovaVeta BIT, -- 1 = validace nové věty, 0 = validace opravy
@NovaVetaExt BIT -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS

IF EXISTS(SELECT*FROM #TempDefForm_Validace WHERE mnozstvi > 10)
BEGIN
RAISERROR(N'je zadáno více než 10', 16, 1)
RETURN
END
GO

