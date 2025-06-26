USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_editor_PolKoopObj_mat_na_VK]    Script Date: 26.06.2025 12:59:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_editor_PolKoopObj_mat_na_VK]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS

DECLARE @Datum DATETIME
SET @Datum=(SELECT _TermPrijKoopPolKont FROM #TempDefForm_Validace_EXT)
IF @Datum IS NOT NULL
BEGIN
UPDATE tpe SET _EXT_RS_material_na_vstupu=1
FROM #TempDefForm_Validace
LEFT OUTER JOIN TabPolKoopObj polkoo ON polkoo.ID=#TempDefForm_Validace.ID
LEFT OUTER JOIN TabPrikaz tp ON tp.ID=polkoo.IDPrikaz
LEFT OUTER JOIN TabPrikaz_EXT tpe ON tpe.ID=tp.ID
WHERE polkoo.ID=#TempDefForm_Validace.ID
END
GO

