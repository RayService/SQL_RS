USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UlozeniCenyPoslPrijmu]    Script Date: 26.06.2025 13:37:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_UlozeniCenyPoslPrijmu] @ID INT
AS 
IF OBJECT_ID('tempdb..#Polozky') IS NOT NULL DROP TABLE #Polozky
CREATE TABLE #Polozky (ID INT,Cena NUMERIC(19,6))
INSERT INTO #Polozky (ID,Cena)
SELECT tss.ID, AVG(tpz.JCevidSN)
FROM TabPohybyZbozi tpz WITH(NOLOCK)
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.ID=tpz.IDZboSklad
WHERE tpz.IDDOklad=@ID
GROUP BY tss.ID

MERGE TabStavSkladu_EXT AS TARGET
USING #Polozky AS SOURCE
ON TARGET.ID=SOURCE.ID
WHEN MATCHED THEN
UPDATE SET TARGET._EXT_RS_LastReceiptPrice=SOURCE.Cena
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID,_EXT_RS_LastReceiptPrice)
VALUES (ID,Cena)
;
/*
UPDATE tsse SET _EXT_RS_LastReceiptPrice=(SELECT TOP 1 tpz.JCevidSN
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
WHERE
((tdz.PoradoveCislo >= 0)AND(tpz.IDZboSklad = tss.ID)AND(tdz.Realizovano=1)AND(tdz.DruhPohybuZbo=0))AND((tdz.RadaDokladu=N'500')OR(tdz.RadaDokladu=N'501')OR(tdz.RadaDokladu=N'522'))
ORDER BY tpz.SkutecneDatReal DESC)
FROM TabStavSkladu tss
LEFT OUTER JOIN TabStavSkladu_EXT tsse WITH(NOLOCK) ON tsse.ID=tss.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.IDZboSklad=tss.ID
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
--WHERE (tss.ID = 85259)

*/
GO

