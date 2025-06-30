USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VypocetHodnotKmenZbozi115]    Script Date: 30.06.2025 8:36:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VypocetHodnotKmenZbozi115]
AS

SET NOCOUNT ON;

--výpočet sloupce _EXT_RS_PolozkaVPozadavkuNakupu, Pokud byla položka v uplynulých dvou letech vložena do požadavku na nákup (doklady řady 440), tak bude haklík.
--Vytvoření nového sloupce s názvem: Množství k převodu na 115. Ten bude počítat následovně: Množství k dispozici po P/V - Množství plánovaná výroba LPP (_EXT_RS_MnozstviPlanovanaVyrobaLPP)

--dočasná tabule s kmenovými kartami
IF OBJECT_ID('tempdb..#TabKmenUdaje') IS NOT NULL DROP TABLE #TabKmenUdaje
CREATE TABLE #TabKmenUdaje (ID INT IDENTITY(1,1) NOT NULL, IDKmen INT NOT NULL, Nakoupeno NUMERIC(19,6), MnoDispo NUMERIC(19,6), MnoPlanVyrLPP NUMERIC(19,6), NakoupenoBit BIT)
INSERT INTO #TabKmenUdaje (IDKmen, Nakoupeno, MnoDispo, MnoPlanVyrLPP, NakoupenoBit)
SELECT tkz.ID, 0, ISNULL(tss.MnozDispoSPrijBezVyd,0), ISNULL(tkze._EXT_RS_MnozstviPlanovanaVyrobaLPP,0), 0
FROM TabKmenZbozi tkz WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'

--SELECT *
--FROM #TabKmenUdaje
--WHERE Nakoupeno<>0

UPDATE k SET k.Nakoupeno=ISNULL(Nakup.Nakoupeno,0)
FROM #TabKmenUdaje k
LEFT OUTER JOIN (SELECT tkz.ID AS IDTabKmen, SUM(tpz.Mnozstvi) AS Nakoupeno
FROM TabPohybyZbozi tpz WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=tpz.IDDoklad AND tdz.DruhPohybuZbo=11 AND tdz.RadaDokladu='440' AND tdz.DatPorizeni>=GETDATE()-730
WHERE tpz.DruhPohybuZbo=11 /*AND tkz.ID=230289*/ AND tdz.RadaDokladu='440' AND tdz.DatPorizeni>=GETDATE()-1730
GROUP BY tkz.ID) AS Nakup ON Nakup.IDTabKmen=k.IDKmen

UPDATE #TabKmenUdaje SET NakoupenoBit=CASE WHEN Nakoupeno<>0 THEN 1 ELSE 0 END

--SELECT *
--FROM #TabKmenUdaje
--WHERE Nakoupeno<>0

MERGE TabKmenZbozi_EXT AS TARGET
USING #TabKmenUdaje AS SOURCE
ON TARGET.ID=SOURCE.IDKmen
WHEN MATCHED THEN
UPDATE SET TARGET._EXT_RS_PolozkaVPozadavkuNakupu=SOURCE.NakoupenoBIT, TARGET._EXT_RS_MnozstviKPrevodu115=SOURCE.MnoDispo-SOURCE.MnoPlanVyrLPP
WHEN NOT MATCHED BY TARGET THEN
INSERT (ID, _EXT_RS_PolozkaVPozadavkuNakupu, _EXT_RS_MnozstviKPrevodu115)
VALUES (SOURCE.IDKmen, SOURCE.NakoupenoBIT, SOURCE.MnoDispo-SOURCE.MnoPlanVyrLPP)
;
GO

