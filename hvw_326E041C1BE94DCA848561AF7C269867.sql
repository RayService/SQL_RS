USE [RayService]
GO

/****** Object:  View [dbo].[hvw_326E041C1BE94DCA848561AF7C269867]    Script Date: 03.07.2025 11:04:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_326E041C1BE94DCA848561AF7C269867] AS 
SELECT tp.Plan_zadani_X AS 'Planovane_zadani',
tkz.CisloZbozi AS 'Cislo_zbozi',
tkz.Nazev1 AS 'Nazev1',
tss.MnozstviKPrijmu AS 'Mnozstvi_k_prijmu',
prkv.IDPrikaz AS 'ID_puvod',
(CASE WHEN (ISNULL((prkv.IDPrikaz),0)<>0) THEN 'Výrobní příkaz' ELSE NULL END) AS 'A',
prkv.nizsi AS 'IDPripravku',
prkv.ID AS 'IDVazby',
prkv.nizsi AS 'nizsi'
FROM TabPrKVazby prkv WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=prkv.nizsi
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=prkv.IDPrikaz
WHERE tp.Plan_zadani_X>'2021-01-01' AND tss.Mnozstvi>0  AND tp.KmenoveStredisko <> N'20000215100' AND prkv.IDOdchylkyDo IS NULL AND prkv.prednastaveno=1 AND tkz.SkupZbo='605'
UNION
SELECT tplp.Plan_zadani_X AS 'Planovane_zadani',
tkz.CisloZbozi AS 'Cislo_zbozi',
tkz.Nazev1 AS 'Nazev1',
tss.MnozstviKPrijmu AS 'Mnozstvi_k_prijmu',
plprkv.IDPlan AS 'ID_puvod',
(CASE WHEN (ISNULL((plprkv.IDPlanPrikaz),0)<>0) THEN 'Výrobní plán' ELSE NULL END) AS 'A',
plprkv.nizsi AS 'IDPripravku',
plprkv.ID AS 'IDVazby',
plprkv.nizsi AS 'nizsi'
FROM TabPlanPrKVazby plprkv WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=plprkv.nizsi
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='100'
LEFT OUTER JOIN TabPlanPrikaz tplp WITH(NOLOCK) ON tplp.ID=plprkv.IDPlanPrikaz
WHERE tplp.Plan_zadani_X>'2021-01-01' AND tss.Mnozstvi>0 AND tplp.KmenoveStredisko <> N'20000215100' AND tkz.SkupZbo='605'
GO

