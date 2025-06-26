USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PlneniPoradiOperace_Logis]    Script Date: 26.06.2025 15:35:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PlneniPoradiOperace_Logis]
AS
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#TabPoradi') IS NOT NULL DROP TABLE #TabPoradi
CREATE TABLE #TabPoradi (ID INT IDENTITY(1,1) NOT NULL, IDPrikaz INT NOT NULL, IDOperace INT NOT NULL, Doklad INT NOT NULL, Operace NVARCHAR(4) NOT NULL, Kusy_vyrob NUMERIC(19,6) NOT NULL, Poradi INT NULL, Splneno BIT NULL)

UPDATE TabPrPostup_EXT SET _EXT_RS_PoradiLogis = NULL

;WITH Poradi AS (
SELECT prp.IDPrikaz, prp.ID, prp.Doklad, prp.Operace, PrP.Kusy_real+PrP.Kusy_zmet+PrP.Kusy_zmet_neopr AS Kusy_vyrob, prp.Splneno
FROM TabPrikaz P 
INNER JOIN TabKmenZbozi KZV ON (KZV.ID=P.IDTabKmen) 
INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
INNER JOIN TabPrPostup PrP ON (PrP.IDPrikaz=P.ID AND PrP.Prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL AND PrP.dilec=P.IDTabKmen AND PrP.Uzavreno=0) 
WHERE P.StavPrikazu IN (20,30,40) AND SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND (PrP.Pracoviste IS NULL OR (PrP.Pracoviste<>164 AND PrP.Pracoviste<>51)) 
)
INSERT INTO #TabPoradi (IDPrikaz, IDOperace, Doklad, Operace, Kusy_vyrob, Poradi)
SELECT IDPrikaz, ID, Doklad, Operace, Kusy_vyrob, ROW_NUMBER() OVER (PARTITION BY Poradi.IDPrikaz ORDER BY  Poradi.IDPrikaz ASC, Poradi.Splneno DESC, Poradi.Kusy_vyrob DESC, Poradi.Operace ASC, Poradi.Doklad ASC)
FROM Poradi

--SELECT *
--FROM #TabPoradi
--ORDER BY IDPrikaz ASC, Poradi ASC

MERGE TabPrPostup_EXT AS TARGET
USING #TabPoradi AS SOURCE
ON TARGET.ID=SOURCE.IDOperace
WHEN MATCHED THEN
UPDATE SET TARGET._EXT_RS_PoradiLogis=SOURCE.Poradi
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_PoradiLogis)
VALUES (IDOperace, Poradi)
;
GO

