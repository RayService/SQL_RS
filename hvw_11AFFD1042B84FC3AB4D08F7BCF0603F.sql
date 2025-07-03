USE [RayService]
GO

/****** Object:  View [dbo].[hvw_11AFFD1042B84FC3AB4D08F7BCF0603F]    Script Date: 03.07.2025 10:55:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_11AFFD1042B84FC3AB4D08F7BCF0603F] AS SELECT
prp.ID AS ID
,prp.Doklad AS Doklad
,prp.IDPrikaz AS IDPrikaz
,prp.Prednastaveno AS Prednastaveno
,prp.Kusy_odv AS Kusy_odv
,prp.Pozastaveno AS Pozastaveno
,prp.Uzavreno AS Uzavreno
,prp.Odchylkovano AS Odchylkovano
,prp.Splneno AS Splneno 
,prp.typ AS typ
,prp.Operace AS Operace
,prp.pracoviste AS pracoviste
,prp.tarif AS tarif
,prp.nazev AS nazev
,(((prp.Kusy_zad * prp.TAC_S / (60.0 * prp.DavkaTPV_VO)))+prp.TBC_N) AS _DS_RS_celkovy_cas_pripravny_jednicovy
,(SELECT ISNULL(SUM(MZ.Sk_cas_N),0) FROM TabPrikazMzdyAZmetky MZ WITH(NOLOCK) WHERE 
MZ.IDPrikaz=prp.IDprikaz AND MZ.DokladPrPostup=prp.Doklad AND MZ.AltPrPostup=prp.Alt
AND MZ.stav=1) AS _EXT_reported_time_min
,prpe._EXT_RS_DatSplneni
FROM TabPrPostup prp WITH(NOLOCK)
LEFT OUTER JOIN  TabPrPostup_EXT prpe WITH(NOLOCK) ON prpe.ID=prp.ID
LEFT OUTER JOIN TabCPraco tcpo WITH(NOLOCK) ON prp.Pracoviste=tcpo.ID
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON prp.IDPrikaz=tp.ID
WHERE
(prp.IDOdchylkyDo IS NULL)AND((prp.Uzavreno=0)AND(prp.Splneno=1))
AND(tcpo.IDTabStrom=N'20023000')
AND(tp.Rada<=N'500')
GO

