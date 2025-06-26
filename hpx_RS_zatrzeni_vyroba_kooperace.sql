USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zatrzeni_vyroba_kooperace]    Script Date: 26.06.2025 12:48:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_zatrzeni_vyroba_kooperace]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS

DECLARE @DatMat DATETIME
SET @DatMat=(SELECT PotvrzTerDod
			FROM #TempDefForm_Validace)
			--LEFT OUTER JOIN TabKoopObj koob ON koob.ID=#TempDefForm_Validace.ID)
--IF EXISTS(SELECT*FROM #TempDefForm_Validace)
IF (@DatMat IS NOT NULL)
BEGIN
  UPDATE tpe SET tpe._Popisstavu2=1
  FROM #TempDefForm_Validace
  LEFT OUTER JOIN TabKoopObj koob ON koob.ID=#TempDefForm_Validace.ID
  LEFT OUTER JOIN TabPolKoopObj polkoo ON polkoo.IDObjednavky=koob.ID
  LEFT OUTER JOIN TabPrikaz tp ON tp.ID=polkoo.IDPrikaz
  LEFT OUTER JOIN TabPrikaz_EXT tpe ON tpe.ID=tp.ID
  WHERE koob.ID=#TempDefForm_Validace.ID
END;
GO

