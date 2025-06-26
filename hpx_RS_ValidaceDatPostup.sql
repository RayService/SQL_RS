USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ValidaceDatPostup]    Script Date: 26.06.2025 16:02:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ValidaceDatPostup]
AS

DECLARE @Operace NCHAR(4)
SET @Operace=(SELECT Operace FROM #TempDefForm_Validace)
SELECT COUNT(tp.ID),tp.dilec,tp.Operace
FROM TabPostup tp
LEFT OUTER JOIN TabCzmeny tczOd ON tp.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo ON tp.ZmenaDo=tczDo.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON tp.dilec=tkz.ID
WHERE
(((tp.IDZakazModif IS NOT NULL OR  tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE() AND 
(tczDo.platnostTPV=0 OR tp.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) )))
GROUP BY tp.dilec, tp.Operace
HAVING COUNT(tp.ID)>1
GO

