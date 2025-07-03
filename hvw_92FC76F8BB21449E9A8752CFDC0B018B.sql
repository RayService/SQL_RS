USE [RayService]
GO

/****** Object:  View [dbo].[hvw_92FC76F8BB21449E9A8752CFDC0B018B]    Script Date: 03.07.2025 12:42:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_92FC76F8BB21449E9A8752CFDC0B018B] AS SELECT 
(SELECT CONVERT(numeric(19,6), CASE WHEN ISNULL(PN.TypZivotnosti,0)=0 THEN NULL 
WHEN ISNULL(tpnv.DobaPouzitiPodle,0)=1 THEN PP.mnoz_zad * tpnv.mnozstvi * ISNULL(tpnv.DobaPouziti_N/tpnv.DavkaTPV,0.0)
ELSE PP.mnoz_zad * tpnv.mnozstvi * ISNULL((SELECT PrP.TAC_N/PrP.DavkaTPV_VO 
FROM TabPrPostup PrP WITH(NOLOCK)
WHERE PrP.IDPrikaz=tpnv.IDPrikaz AND PrP.Doklad=dbo.hf_GetPrPDokladForPrNV(tpnv.ID) AND PrP.IDOdchylkyDo IS NULL AND (PrP.Alt=tpnv.AltOperace OR ISNULL(tpnv.AltOperace,'')='' AND PrP.Prednastaveno=1)),0.0) END) 
FROM TabPrikazP PP WITH(NOLOCK) LEFT OUTER JOIN TabParNar PN WITH(NOLOCK) ON (PN.IDKmenZbozi=tpnv.naradi)
WHERE PP.IDPrikaz=tpnv.IDPrikaz AND PP.IDTabKmen=tpnv.Dilec AND PP.mnoz_zad>0.0) AS 'Doba_pouziti',
/*
(SELECT CONVERT(numeric(19,6), CASE WHEN ISNULL(PN.TypZivotnosti,0)=0 THEN NULL 
WHEN ISNULL(tpnv.DobaPouzitiPodle,0)=1 THEN PP.mnoz_zad * tpnv.mnozstvi * ISNULL(tpnv.DobaPouziti_N/tpnv.DavkaTPV,0.0)
ELSE PP.mnoz_zad * tpnv.mnozstvi * ISNULL((SELECT PrP.TAC_N/PrP.DavkaTPV_VO 
FROM TabPrPostup PrP WITH(NOLOCK)
WHERE PrP.IDPrikaz=tpnv.IDPrikaz AND PrP.Doklad=dbo.hf_GetPrPDokladForPrNV(tpnv.ID) AND PrP.IDOdchylkyDo IS NULL AND (PrP.Alt=tpnv.AltOperace OR ISNULL(tpnv.AltOperace,'')='' AND PrP.Prednastaveno=1)),0.0) END) 
FROM TabPrikazP PP WITH(NOLOCK) LEFT OUTER JOIN TabParNar PN WITH(NOLOCK) ON (PN.IDKmenZbozi=tpnv.naradi)
WHERE PP.IDPrikaz=tpnv.IDPrikaz AND PP.IDTabKmen=tpnv.Dilec AND PP.mnoz_zad>0.0)/tss.MnozstviKPrijmu/60 AS 'Doba_pouziti_1ks',*/

tp.Plan_zadani_X AS 'Planovane_zadani',
tkz.CisloZbozi AS 'Cislo_zbozi',
tkz.Nazev1 AS 'Nazev1',
tss.MnozstviKPrijmu AS 'Mnozstvi_k_prijmu',
tpnv.IDPrikaz AS 'ID_puvod',
(CASE WHEN (ISNULL((tpnv.IDPrikaz),0)<>0) THEN 'Výrobní příkaz' ELSE NULL END) AS 'A',
tpnv.Naradi AS 'IDNaradi',
tpnv.Operace AS 'Operace',
tpnve._EXT_RS_ContraPartPosition AS 'Protikus',
tpnve._EXT_RS_TesterPosition AS 'Pozice_testeru',
tpnve._EXT_RS_ProductConnector AS 'Konektor_vyrobku',
tpnve._EXT_RS_BranchDesc AS 'Oznaceni_vetve',
tpnve._EXT_RS_Obrazek AS 'Obrazek',
prp.ID AS 'IDOperace'

FROM TabPrNVazby tpnv WITH(NOLOCK)
LEFT OUTER JOIN TabPrNVazby_EXT tpnve WITH(NOLOCK) ON tpnve.ID=tpnv.ID
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tpnv.Naradi
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='20000280282'
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=tpnv.IDPrikaz
LEFT OUTER JOIN TabPrPostup prp ON prp.IDPrikaz=tpnv.IDPrikaz AND prp.Doklad=dbo.hf_GetPrPDokladForPrNV(tpnv.ID) AND (prp.Alt=tpnv.AltOperace OR ISNULL(tpnv.AltOperace,'')='' AND prp.prednastaveno=1) AND prp.IDOdchylkyDo IS NULL
WHERE tp.Plan_zadani_X>'2021-01-01'
--AND tss.MnozstviKPrijmu>0 
AND tp.KmenoveStredisko <> N'20000215100'
AND tkz.SkupZbo=N'899'

UNION

SELECT tplnv.DobaPouziti_N AS 'Doba_pouziti',
/*tplnv.DobaPouziti_N/tss.MnozstviKPrijmu/60 AS 'Doba_pouziti_1ks',*/
tplp.Plan_zadani_X AS 'Planovane_zadani',
tkz.CisloZbozi AS 'Cislo_zbozi',
tkz.Nazev1 AS 'Nazev1',
tss.MnozstviKPrijmu AS 'Mnozstvi_k_prijmu',
tplnv.IDPlan AS 'ID_puvod',
(CASE WHEN (ISNULL((tplnv.IDPlanPrikaz),0)<>0) THEN 'Výrobní plán' ELSE NULL END) AS 'A',
tplnv.Naradi AS 'IDNaradi',
tplnv.Operace AS 'Operace',
tplnve._EXT_RS_ContraPartPosition AS 'Protikus',
tplnve._EXT_RS_TesterPosition AS 'Pozice_testeru',
tplnve._EXT_RS_ProductConnector AS 'Konektor_vyrobku',
tplnve._EXT_RS_BranchDesc AS 'Oznaceni_vetve',
tplnve._EXT_RS_Obrazek AS 'Obrazek',
prpl.ID AS 'IDOperace'

FROM TabPlanPrNVazby tplnv WITH(NOLOCK)
LEFT OUTER JOIN TabPlanPrNVazby_EXT tplnve WITH(NOLOCK) ON tplnve.ID=tplnv.ID
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tplnv.Naradi
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='20000280282'
LEFT OUTER JOIN TabPlanPrikaz tplp WITH(NOLOCK) ON tplp.ID=tplnv.IDPlanPrikaz
LEFT OUTER JOIN TabPlanPrPostup prpl ON prpl.IDPlanPrikaz=tplnv.IDPlanPrikaz AND prpl.Doklad=dbo.hf_GetPlanPrPDokladForPrNV(tplnv.ID) AND (prpl.Alt=tplnv.AltOperace OR ISNULL(tplnv.AltOperace,'')='' AND prpl.prednastaveno=1)
WHERE tplp.Plan_zadani_X>'2021-01-01'
--AND tss.MnozstviKPrijmu>0
AND tplp.KmenoveStredisko <> N'20000215100'
AND tkz.SkupZbo=N'899'
GO

