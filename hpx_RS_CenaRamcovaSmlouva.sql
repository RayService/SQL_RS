USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_CenaRamcovaSmlouva]    Script Date: 26.06.2025 13:21:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_CenaRamcovaSmlouva]
AS
/*
Ahoj,
Prosím o nové pole „Cena z rámcové smlouvy“ nad skladovou kartou (stav skladu)
Stačí napočíst 1x za den.
Měl by natáhnout cenu (JC bez daní) z poslední (nejaktuálnější) nabídky řady 380 nebo 381, která má _RAY_ZbyvaProPrevod více než 0
Sklad pro pohyb brát dle výchozího skladu pro výdej do výroby z kmenové karty.
*/
IF OBJECT_ID('tempdb..#Cena') IS NOT NULL DROP TABLE #Cena
CREATE TABLE #Cena (ID INT IDENTITY(1,1),IDKmenZbozi INT, Cena NUMERIC(19,6))

;WITH Pol AS (SELECT tkz.ID AS IDKmenZbozi
,tpz.JCbezDaniKc AS Cena ,tpz.DatPorizeni AS Datum
,parkmz.VychoziSklad AS VychoziSklad
,RANK() OVER (PARTITION BY tkz.ID ORDER BY tpz.DatPorizeni DESC) AS rn
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=tpz.IDZboSklad
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabParametryKmeneZbozi parkmz ON tkz.ID=parkmz.IDKmenZbozi
WHERE (
((tpz.Mnozstvi-
(SELECT ISNULL(SUM(P.Mnozstvi),0) FROM TabPohybyZbozi P WITH(NOLOCK)
WHERE P.IDOldPolozka = tpz.ID)
)>0)
AND((tdz.RadaDokladu=N'380' OR tdz.RadaDokladu=N'381'))AND(tdz.DruhPohybuZbo=11)
AND(tss.IDSklad=parkmz.VychoziSklad)
)
)
INSERT INTO #Cena (IDKmenZbozi, Cena)
SELECT IDKmenZbozi, Cena
FROM Pol
WHERE rn=1 AND Cena<>0

--SELECT * FROM #Cena

MERGE dbo.TabKmenZbozi_EXT AS TARGET
USING #Cena AS SOURCE
ON TARGET.ID=SOURCE.IDKmenZbozi
WHEN MATCHED THEN
UPDATE SET TARGET._EXT_RS_RamcSmlCena=SOURCE.Cena
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_RamcSmlCena)
VALUES (SOURCE.IDKmenZbozi, SOURCE.Cena)
WHEN NOT MATCHED BY SOURCE THEN
UPDATE SET TARGET._EXT_RS_RamcSmlCena=NULL
;


GO

