USE [RayService]
GO

/****** Object:  View [dbo].[hvw_931D88AF208A4E7EBBCF4C37C169AC48]    Script Date: 03.07.2025 12:42:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_931D88AF208A4E7EBBCF4C37C169AC48] AS --pocet polozek mesic celkem
SELECT
vcp.ID AS IDVCP
,tpz.ID AS IDPZ
,tdz.ID AS IDDoklad
,tp.ID AS IDPrikaz
,1 AS Stav
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WITH(NOLOCK) WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y>=2021/*DATEPART(YEAR,GETDATE())*/)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500'))
AND(tpl.Rada=N'Plan_fix')
GROUP BY vcp.ID,tpz.ID,tdz.ID,tp.ID

UNION ALL
--pocet polozek mesic spatne
SELECT
vcp.ID AS IDVCP
,tpz.ID AS IDPZ
,tdz.ID AS IDDoklad
,tp.ID AS IDPrikaz
,0 AS Stav
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WITH(NOLOCK) WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y>=2021/*DATEPART(YEAR,GETDATE())*/)
AND(tdz.DatPorizeni_X>ISNULL(tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500'))
AND(tpl.Rada=N'Plan_fix')
GROUP BY vcp.ID,tpz.ID,tdz.ID,tp.ID
GO

