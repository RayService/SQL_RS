USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZrusOznaceniESDMat]    Script Date: 26.06.2025 14:16:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZrusOznaceniESDMat]
AS

--položky pro odznačení do automatu
IF OBJECT_ID('tempdb..#TabZrusOznac') IS NOT NULL DROP TABLE #TabZrusOznac
CREATE TABLE #TabZrusOznac (ID INT IDENTITY(1,1) NOT NULL, IDMat INT NOT NULL)
INSERT INTO #TabZrusOznac (IDMat)
SELECT DISTINCT tkzN.ID
FROM TabKvazby kv
LEFT OUTER JOIN TabCzmeny tcOd ON kv.ZmenaOd=tcOd.ID
LEFT OUTER JOIN TabCzmeny tcDo ON kv.ZmenaDo=tcDo.ID
LEFT OUTER JOIN TabKmenZbozi tkzV ON tkzV.ID=kv.vyssi
LEFT OUTER JOIN TabKmenZbozi_EXT tkzV_EXT ON tkzV_EXT.ID=tkzV.ID
LEFT OUTER JOIN TabKmenZbozi tkzN ON kv.nizsi=tkzN.ID
LEFT OUTER JOIN TabKmenZbozi_EXT tkzN_EXT ON tkzN_EXT.ID=tkzN.ID
WHERE
(((kv.IDZakazModif IS NOT NULL OR tcOd.platnostTPV=1 AND tcOd.datum<=GETDATE() AND (tcDo.platnostTPV=0 OR kv.ZmenaDo IS NULL OR (tcDo.platnostTPV=1 AND tcDo.datum>GETDATE())) )))AND((tkzV_EXT._KvalDil<>N'E')AND(tkzV_EXT._KvalDil<>N'L'))
AND(ISNULL(tkzN_EXT._2NP,0)=1)

--SELECT *
--FROM #TabZrusOznac

MERGE TabKmenZbozi_EXT AS TARGET
USING #TabZrusOznac AS SOURCE
ON TARGET.ID=SOURCE.IDMat
WHEN MATCHED THEN
UPDATE SET TARGET._2NP=0
WHEN NOT MATCHED BY TARGET
THEN INSERT (ID, _2NP)
     VALUES (SOURCE.IDMat, 0)
;
GO

