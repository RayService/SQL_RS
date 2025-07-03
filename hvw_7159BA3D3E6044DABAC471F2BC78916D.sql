USE [RayService]
GO

/****** Object:  View [dbo].[hvw_7159BA3D3E6044DABAC471F2BC78916D]    Script Date: 03.07.2025 11:18:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_7159BA3D3E6044DABAC471F2BC78916D] AS SELECT (SELECT CONVERT(numeric(19,6), CASE WHEN ISNULL(PN.TypZivotnosti,0)=0 THEN NULL 
WHEN ISNULL(tpnv.DobaPouzitiPodle,0)=1 THEN PP.mnoz_zad * tpnv.mnozstvi * ISNULL(tpnv.DobaPouziti_N/tpnv.DavkaTPV,0.0)
ELSE PP.mnoz_zad * tpnv.mnozstvi * ISNULL((SELECT PrP.TAC_N/PrP.DavkaTPV_VO 
FROM TabPrPostup PrP WITH(NOLOCK)
WHERE PrP.IDPrikaz=tpnv.IDPrikaz AND PrP.Doklad=dbo.hf_GetPrPDokladForPrNV(tpnv.ID) AND PrP.IDOdchylkyDo IS NULL AND (PrP.Alt=tpnv.AltOperace OR ISNULL(tpnv.AltOperace,'')='' AND PrP.Prednastaveno=1)),0.0) END) 
FROM TabPrikazP PP WITH(NOLOCK) LEFT OUTER JOIN TabParNar PN WITH(NOLOCK) ON (PN.IDKmenZbozi=tpnv.naradi)
WHERE PP.IDPrikaz=tpnv.IDPrikaz AND PP.IDTabKmen=tpnv.Dilec AND PP.mnoz_zad>0.0) AS 'Doba_pouziti',
(SELECT CONVERT(numeric(19,6), CASE WHEN ISNULL(PN.TypZivotnosti,0)=0 THEN NULL 
WHEN ISNULL(tpnv.DobaPouzitiPodle,0)=1 THEN PP.mnoz_zad * tpnv.mnozstvi * ISNULL(tpnv.DobaPouziti_N/tpnv.DavkaTPV,0.0)
ELSE PP.mnoz_zad * tpnv.mnozstvi * ISNULL((SELECT PrP.TAC_N/PrP.DavkaTPV_VO 
FROM TabPrPostup PrP WITH(NOLOCK)
WHERE PrP.IDPrikaz=tpnv.IDPrikaz AND PrP.Doklad=dbo.hf_GetPrPDokladForPrNV(tpnv.ID) AND PrP.IDOdchylkyDo IS NULL AND (PrP.Alt=tpnv.AltOperace OR ISNULL(tpnv.AltOperace,'')='' AND PrP.Prednastaveno=1)),0.0) END) 
FROM TabPrikazP PP WITH(NOLOCK) LEFT OUTER JOIN TabParNar PN WITH(NOLOCK) ON (PN.IDKmenZbozi=tpnv.naradi)
WHERE PP.IDPrikaz=tpnv.IDPrikaz AND PP.IDTabKmen=tpnv.Dilec AND PP.mnoz_zad>0.0)/tss.MnozstviKPrijmu/60 AS 'Doba_pouziti_1ks',
tp.Plan_zadani_X AS 'Planovane_zadani',
tkz.CisloZbozi AS 'Cislo_zbozi',
tkz.Nazev1 AS 'Nazev1',
tss.MnozstviKPrijmu AS 'Mnozstvi_k_prijmu',
tpnv.IDPrikaz AS 'ID_puvod',
(CASE WHEN (ISNULL((tpnv.IDPrikaz),0)<>0) THEN 'Výrobní příkaz' ELSE NULL END) AS 'A',
tpnv.Naradi AS 'IDNaradi'
FROM TabPrNVazby tpnv WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tpnv.Naradi
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='10000140147'
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=tpnv.IDPrikaz
WHERE tp.Plan_zadani_X>'2021-01-01' AND tss.MnozstviKPrijmu>0  AND tp.KmenoveStredisko <> N'20000215100'
UNION
SELECT tplnv.DobaPouziti_N AS 'Doba_pouziti',
tplnv.DobaPouziti_N/tss.MnozstviKPrijmu/60 AS 'Doba_pouziti_1ks',
tplp.Plan_zadani_X AS 'Planovane_zadani',
tkz.CisloZbozi AS 'Cislo_zbozi',
tkz.Nazev1 AS 'Nazev1',
tss.MnozstviKPrijmu AS 'Mnozstvi_k_prijmu',
tplnv.IDPlan AS 'ID_puvod',
(CASE WHEN (ISNULL((tplnv.IDPlanPrikaz),0)<>0) THEN 'Výrobní plán' ELSE NULL END) AS 'A',
tplnv.Naradi AS 'IDNaradi'
FROM TabPlanPrNVazby tplnv WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tplnv.Naradi
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='10000140147'
LEFT OUTER JOIN TabPlanPrikaz tplp WITH(NOLOCK) ON tplp.ID=tplnv.IDPlanPrikaz
WHERE tplp.Plan_zadani_X>'2021-01-01' AND tss.MnozstviKPrijmu>0 AND tplp.KmenoveStredisko <> N'20000215100'
GO

