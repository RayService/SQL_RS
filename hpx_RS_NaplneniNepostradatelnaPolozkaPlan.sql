USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NaplneniNepostradatelnaPolozkaPlan]    Script Date: 26.06.2025 13:25:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NaplneniNepostradatelnaPolozkaPlan]
AS
IF OBJECT_ID('tempdb..#TabPlanNePol') IS NOT NULL DROP TABLE #TabPlanNePol
CREATE TABLE #TabPlanNePol (ID INT IDENTITY(1,1), IDPlan INT NOT NULL)

INSERT INTO #TabPlanNePol(IDPlan)
SELECT
tp.ID
FROM TabPlan tp WITH(NOLOCK)
LEFT OUTER JOIN TabKvazby tkv WITH(NOLOCK) ON tkv.vyssi=tp.IDTabKmen
LEFT OUTER JOIN TabCzmeny tczOd WITH(NOLOCK) ON tkv.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo WITH(NOLOCK) ON tkv.ZmenaDo=tczDo.ID
LEFT OUTER JOIN TabKvazby_EXT WITH(NOLOCK) ON TabKvazby_EXT.ID=tkv.ID
LEFT OUTER JOIN TabKmenZbozi tkzn WITH(NOLOCK) ON tkv.nizsi=tkzn.ID
WHERE
(
(ISNULL(TabKvazby_EXT._NepPol,0)=1)AND
((tczOd.platnostTPV=1 AND tczOd.datum<=ISNULL(tp.DatumTPV,GETDATE())))
AND(((tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>ISNULL(tp.DatumTPV,GETDATE()))) ))
--AND(tp.ID=131141)
AND(tp.InterniZaznam=0)AND((tp.StavPrevodu<>N'x')AND(tp.datum_Y>=2014)AND(tp.Rada <> 'PT_Burza'))
)
GROUP BY tp.ID,tp.DatumTPV

SELECT * FROM #TabPlanNePol

/*SELECT
TabPlan.ID
FROM TabPlan WITH(NOLOCK)
WHERE
(TabPlan.InterniZaznam=0)AND((TabPlan.StavPrevodu<>N'x')AND(TabPlan.datum_Y>=2014)AND(TabPlan.Rada <> 'PT_Burza'))
*/

MERGE TabPlan_EXT AS TARGET
USING #TabPlanNePol AS SOURCE
ON TARGET.ID=SOURCE.IDPlan
WHEN MATCHED THEN
UPDATE SET TARGET._EXT_RS_indispensableItem=1
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID,_EXT_RS_indispensableItem)
VALUES (IDPlan,1)
;



GO

