USE [RayService]
GO

/****** Object:  View [dbo].[hvw_B1E35595F5B2424AAC7695CCCB8F6EE2]    Script Date: 03.07.2025 13:38:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_B1E35595F5B2424AAC7695CCCB8F6EE2] AS SELECT
plkv.ID AS ID
,plkv.IDPlan AS IDZDroj
,plkv.Doklad,plkv.Kusy_zad,plkv.dilec AS IDDilce
,plkv.typ,plkv.DavkaTPV,plkv.Operace,plkv.nazev,plkv.pracoviste AS Pracoviste_ID
,plkv.IDkooperace
,plkv.TBC,plkv.TBC_T,plkv.TBC_Obsluhy,plkv.TBC_Obsluhy_T
,plkv.TEC,plkv.TEC_T,plkv.TEC_Obsluhy,plkv.TEC_Obsluhy_T
,plkv.NasobekTAC
,plkv.TAC_J,plkv.TAC_J_T,plkv.TAC_Obsluhy_J,plkv.TAC_Obsluhy_J_T
,plkv.KoopMnozstvi/*,plkv.Poznamka*/
,plkv.KVO
,plkv.PocetLidi AS PocetLidi
,plkv.PocetKusu
,plkv.PocetStroju
,plkv.MeziOperCas,plkv.MeziOperCas_T
,plkv.Autor
,plkv.DatPorizeni AS DatPorizeni
,plkv.tarif AS IDTarif
,plkv.VyraditZKontrolyPosloupOper
,plkv.IDPlanPrikaz AS IDplanprikaz
,NULL AS Predzpracovano
,NULL AS Prednastaveno
,NULL AS Odvadeci
,NULL AS Odchylkovano
,(plkv.Kusy_zad * plkv.TAC_S / (3600.0 * plkv.DavkaTPV_VO)) AS CelkovyCasNaDavku
,0 AS Zdroj
,tcp.IDTabStrom AS Stredisko
,tcp.Pracoviste AS Pracoviste
,plpr.Plan_ukonceni_X AS Plan_ukonceni_X
,plpr.Plan_ukonceni_D AS Plan_ukonceni_D
,plpr.Plan_ukonceni_M AS Plan_ukonceni_M
,plpr.Plan_ukonceni_W AS Plan_ukonceni_W
,DATEPART(ISO_WEEK,plpr.Plan_ukonceni) AS Plan_ukonceni_TISO
,plpr.Plan_ukonceni_Q AS Plan_ukonceni_Q
,plpr.Plan_ukonceni_Y AS Plan_ukonceni_Y
,0 AS Kapacita
FROM TabPlanPrPostup plkv WITH(NOLOCK)
LEFT OUTER JOIN TabPlanPrikaz plpr WITH(NOLOCK) ON plkv.IDPlanPrikaz=plpr.ID
LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON plkv.Pracoviste=tcp.ID
UNION
SELECT
prkv.ID AS ID
,prkv.IDPrikaz AS IDZDroj
,prkv.Doklad,prkv.Kusy_zad,prkv.dilec AS IDDilce
,prkv.typ,prkv.DavkaTPV,prkv.Operace
,prkv.nazev
,prkv.pracoviste  AS Pracoviste_ID
,prkv.IDkooperace
,prkv.TBC,prkv.TBC_T,prkv.TBC_Obsluhy,prkv.TBC_Obsluhy_T
,prkv.TEC,prkv.TEC_T,prkv.TEC_Obsluhy,prkv.TEC_Obsluhy_T
,prkv.NasobekTAC
,prkv.TAC_J,prkv.TAC_J_T,prkv.TAC_Obsluhy_J,prkv.TAC_Obsluhy_J_T
,prkv.KoopMnozstvi/*,prkv.Poznamka*/
,prkv.KVO
,prkv.PocetLidi AS PocetLidi
,prkv.PocetKusu
,prkv.PocetStroju
,prkv.MeziOperCas,prkv.MeziOperCas_T
,prkv.Autor
,prkv.DatPorizeni AS DatPorizeni
,prkv.tarif AS IDTarif
,prkv.VyraditZKontrolyPosloupOper
,NULL AS IDplanprikaz
,prkv.predzpracovano AS Predzpracovano
,prkv.Prednastaveno AS Prednastaveno
,prkv.Odvadeci AS Odvadeci
,prkv.Odchylkovano AS Odchylkovano
,(prkv.Kusy_zad * prkv.TAC_S / (3600.0 * prkv.DavkaTPV_VO)) AS CelkovyCasNaDavku
,1 AS Zdroj
,tcp.IDTabStrom AS Stredisko
,tcp.Pracoviste AS Pracoviste
,tp.Plan_ukonceni_X AS Plan_ukonceni_X
,tp.Plan_ukonceni_D AS Plan_ukonceni_D
,tp.Plan_ukonceni_M AS Plan_ukonceni_M
,tp.Plan_ukonceni_W AS Plan_ukonceni_W
,DATEPART(ISO_WEEK,tp.Plan_ukonceni) AS Plan_ukonceni_TISO
,tp.Plan_ukonceni_Q AS Plan_ukonceni_Q
,tp.Plan_ukonceni_Y AS Plan_ukonceni_Y
,0 AS Kapacita
FROM TabPrPostup prkv WITH(NOLOCK)
JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=prkv.IDPrikaz
LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON prkv.Pracoviste=tcp.ID
WHERE tp.StavPrikazu<=40
UNION
SELECT
wc.ID AS ID
,NULL AS IDZDroj
,NULL,0,NULL AS IDDilce
,NULL,0,NULL
,NULL
,wc.IDWorkplace AS Pracoviste_ID
,NULL
,0,NULL,0,NULL
,0,NULL,0,NULL
,0
,0,NULL,0,NULL
,0
,NULL
,wc.WorkerAmount AS PocetLidi
,NULL
,NULL
,NULL
,NULL
,wc.Autor
,wc.Datum AS DatPorizeni
,NULL AS IDTarif
,NULL
,NULL AS IDplanprikaz
,NULL AS Predzpracovano
,NULL AS Prednastaveno
,NULL AS Odvadeci
,NULL AS Odchylkovano
,0 AS CelkovyCasNaDavku
,2 AS Zdroj
,tcp.IDTabStrom AS Stredisko
,tcp.Pracoviste AS Pracoviste
,(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,wc.Datum)))) AS Plan_ukonceni_X
,(DATEPART(DAY,wc.Datum)) AS Plan_ukonceni_D
,(DATEPART(MONTH,wc.Datum)) AS Plan_ukonceni_M
,(DATEPART(WEEK,wc.Datum)) AS Plan_ukonceni_W
,(DATEPART(ISO_WEEK,wc.Datum)) AS Plan_ukonceni_TISO
,(DATEPART(QUARTER,wc.Datum)) AS Plan_ukonceni_Q
,(DATEPART(YEAR,wc.Datum)) AS Plan_ukonceni_Y
,wc.Capacity AS Kapacita
FROM Tabx_RS_workplace_capacity wc WITH(NOLOCK)
LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON wc.IDWorkplace=tcp.ID
GO

