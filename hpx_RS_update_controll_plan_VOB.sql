USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_controll_plan_VOB]    Script Date: 26.06.2025 13:02:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_controll_plan_VOB]
AS
SET NOCOUNT ON

IF (OBJECT_ID('tempdb..#Temp') IS NOT NULL)
BEGIN
DROP TABLE #Temp
END;
CREATE TABLE #Temp 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [IDPol] [INT],
  [KontrolniPlan] [NVARCHAR](30)
)

INSERT INTO #Temp (IDPol,KontrolniPlan)
SELECT tkz.ID,tsze._EXT_RS_controll_plan
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkz_EXT WITH(NOLOCK) ON tkz_EXT.ID=tkz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH (NOLOCK) ON tdz.ID=tpz.IDDoklad
JOIN TabSkupinyZbozi tsz WITH(NOLOCK) ON tsz.SkupZbo=tkz.SkupZbo
LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze WITH(NOLOCK) ON tsze.ID=tsz.ID
WHERE
((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND(tkz_EXT._vstupni_kontrola IS NULL)AND((tdz.DruhPohybuZbo=6)AND((tdz.IDSklad='100')OR(tdz.IDSklad='10000115'))AND(tdz.PoradoveCislo>=0))AND(tdz.Splneno<>1)AND(tsze._EXT_RS_controll_plan IS NOT NULL)
GROUP BY tkz.ID,tsze._EXT_RS_controll_plan

--SELECT * FROM #Temp

MERGE TabKmenZbozi_EXT AS TARGET
USING #Temp AS SOURCE ON
TARGET.ID=SOURCE.IDPol
WHEN MATCHED THEN
UPDATE SET TARGET._vstupni_kontrola=SOURCE.KontrolniPlan
;
GO

