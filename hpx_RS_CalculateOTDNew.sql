USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_CalculateOTDNew]    Script Date: 30.06.2025 8:38:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_CalculateOTDNew]
AS

DECLARE @Week_1_all NUMERIC(19,6)
,@Week_1_NOK NUMERIC(19,6)
,@Month_all NUMERIC(19,6)
,@Month_NOK NUMERIC(19,6)
,@Month_1_all NUMERIC(19,6)
,@Month_1_NOK NUMERIC(19,6)
,@Quarter_all NUMERIC(19,6)
,@Quarter_NOK NUMERIC(19,6)
,@Quarter_1_all NUMERIC(19,6)
,@Quarter_1_NOK NUMERIC(19,6)
,@Year_all NUMERIC(19,6)
,@Year_NOK NUMERIC(19,6)
,@Year_1_all NUMERIC(19,6)
,@Year_1_NOK NUMERIC(19,6)

DELETE FROM Tabx_RS_OTDExternalPBINew
--celkové OTD
--počet položek minulý týden celkem
SET @Week_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND DATEPART(ISO_WEEK,tdz.DatPorizeni)=DATEPART(ISO_WEEK,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix')	--MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963)))	--MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý týden celkem
SET @Week_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND DATEPART(ISO_WEEK,tdz.DatPorizeni)=DATEPART(ISO_WEEK,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek aktuální měsíc celkem
SET @Month_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek špatně aktuální měsíc celkem
SET @Month_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek aktuální kvartál celkem
SET @Quarter_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek špatně aktuální kvartál celkem
SET @Quarter_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek aktuální rok celkem
SET @Year_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně aktuální rok celkem
SET @Year_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý měsíc celkem
SET @Month_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý měsíc celkem
SET @Month_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý kvartál celkem
SET @Quarter_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý kvartál celkem
SET @Quarter_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý rok celkem
SET @Year_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý rok celkem
SET @Year_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)

--uložení dat
INSERT INTO Tabx_RS_OTDExternalPBINew (Week_1_all,Week_1_NOK,Month_all,Month_NOK,Month_1_all,Month_1_NOK,Quarter_all,Quarter_NOK,Quarter_1_all,Quarter_1_NOK,Year_all,Year_NOK,Year_1_all,Year_1_NOK,Type)
VALUES (@Week_1_all,@Week_1_NOK,@Month_all,@Month_NOK,@Month_1_all,@Month_1_NOK,@Quarter_all,@Quarter_NOK,@Quarter_1_all,@Quarter_1_NOK,@Year_all,@Year_NOK,@Year_1_all,@Year_1_NOK,0)



--OTD kabeláž
--počet položek minulý týden celkem
SET @Week_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND DATEPART(ISO_WEEK,tdz.DatPorizeni)=DATEPART(ISO_WEEK,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý týden celkem
SET @Week_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND DATEPART(ISO_WEEK,tdz.DatPorizeni)=DATEPART(ISO_WEEK,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek aktuální měsíc celkem
SET @Month_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek špatně aktuální měsíc celkem
SET @Month_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek aktuální kvartál celkem
SET @Quarter_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek špatně aktuální kvartál celkem
SET @Quarter_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek aktuální rok celkem
SET @Year_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně aktuální rok celkem
SET @Year_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý měsíc celkem
SET @Month_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý měsíc celkem
SET @Month_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý kvartál celkem
SET @Quarter_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý kvartál celkem
SET @Quarter_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý rok celkem
SET @Year_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý rok celkem
SET @Year_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil NOT IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol změněna podmínka AND(tkz.SkupZbo IN ('800','850'))
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--uložení dat
INSERT INTO Tabx_RS_OTDExternalPBINew (Week_1_all,Week_1_NOK,Month_all,Month_NOK,Month_1_all,Month_1_NOK,Quarter_all,Quarter_NOK,Quarter_1_all,Quarter_1_NOK,Year_all,Year_NOK,Year_1_all,Year_1_NOK,Type)
VALUES (@Week_1_all,@Week_1_NOK,@Month_all,@Month_NOK,@Month_1_all,@Month_1_NOK,@Quarter_all,@Quarter_NOK,@Quarter_1_all,@Quarter_1_NOK,@Year_all,@Year_NOK,@Year_1_all,@Year_1_NOK,1)



--OTD mechanika
--počet položek minulý týden celkem
SET @Week_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND DATEPART(ISO_WEEK,tdz.DatPorizeni)=DATEPART(ISO_WEEK,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý týden celkem
SET @Week_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND DATEPART(ISO_WEEK,tdz.DatPorizeni)=DATEPART(ISO_WEEK,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek aktuální měsíc celkem
SET @Month_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek špatně aktuální měsíc celkem
SET @Month_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek aktuální kvartál celkem
SET @Quarter_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek špatně aktuální kvartál celkem
SET @Quarter_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID
) AS S)
--počet položek aktuální rok celkem
SET @Year_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně aktuální rok celkem
SET @Year_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý měsíc celkem
SET @Month_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý měsíc celkem
SET @Month_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_M=DATEPART(MONTH,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý kvartál celkem
SET @Quarter_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý kvartál celkem
SET @Quarter_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()) AND tdz.DatPorizeni_Q=DATEPART(QUARTER,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek minulý rok celkem
SET @Year_1_all=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE())-1)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--počet položek špatně minulý rok celkem
SET @Year_1_NOK=(SELECT COUNT(*) FROM (SELECT
vcs.ID
FROM TabVyrCP vcp WITH(NOLOCK)
LEFT OUTER JOIN TabvyrCP_EXT vcpe WITH(NOLOCK) ON vcpe.ID=vcp.ID
LEFT OUTER JOIN TabVyrCS vcs WITH(NOLOCK) ON vcp.IDVyrCis=vcs.ID
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=vcp.IDPolozkaDokladu
LEFT OUTER JOIN TabPohybyZbozi_Ext TPZE WITH(NOLOCK) ON TPZE.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID IN (SELECT TabPohybyZbozi.IDDoklad FROM TabPohybyZbozi WHERE TabPohybyZbozi.ID=vcp.IDPolozkaDokladu)
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID
LEFT OUTER JOIN TabCisOrg prij WITH(NOLOCK) ON prij.CisloOrg=tdz.MistoUrceni
LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tp.ID=vcpe._EXT_RS_IDPrikaz_orig
LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=tp.IDPlan
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE (tdz.DruhPohybuZbo=2)
AND(tdz.Realizovano=1)
AND((tdz.RadaDokladu=N'655')OR(tdz.RadaDokladu=N'656')OR(tdz.RadaDokladu=N'674'))
AND(tdz.DatPorizeni_Y=DATEPART(YEAR,GETDATE())-1)
AND(tdz.DatPorizeni_X>COALESCE(TPZE._dat_dod1,tpz.PotvrzDatDod_X,tdz.DatPorizeni_X))
AND ((SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) NOT IN ('8. Jiné důvody zákazníka','19. Dovolená, svátky')
OR (SELECT TPZ2E._LCS_PFA_DuvodOpozdeniExp FROM TabPohybyZbozi TPZ2 WITH(NOLOCK) JOIN TabPohybyZbozi_Ext TPZ2E WITH(NOLOCK) ON TPZ2E.ID=TPZ2.ID WHERE TPZ2.ID=tpz.IDOldPolozka) IS NULL)
AND(vcpe._EXT_RS_IDPrikaz_orig IS NOT NULL)
AND(tp.Rada IN ('200','500','300','805','806'))	--MŽ 24.2.2025, na přání MoKol přidány 805 a 806
--AND(tpl.Rada=N'Plan_fix') --MŽ 24.2.2025, na přání MoKol zrušena podmínka na plány
AND((ISNULL(tcoe._shop,0)=1)OR(prij.CisloOrg IN (6621,2963))) --MŽ 25.2.2025, na přání MoKol přidána podmínka na klíčového zákazníka a místo určení Excal, BAE
AND(tkze._KvalDil IN (N'E',N'L')) --MŽ 25.2.2025, na přání MoKol přidána podmínka na E a L
GROUP BY vcs.ID,tdz.ID--,tpz.SkupZbo,tpz.RegCis--,tdz.ID--,tp.ID--,tpl.ID
) AS S)
--uložení dat
INSERT INTO Tabx_RS_OTDExternalPBINew (Week_1_all,Week_1_NOK,Month_all,Month_NOK,Month_1_all,Month_1_NOK,Quarter_all,Quarter_NOK,Quarter_1_all,Quarter_1_NOK,Year_all,Year_NOK,Year_1_all,Year_1_NOK,Type)
VALUES (@Week_1_all,@Week_1_NOK,@Month_all,@Month_NOK,@Month_1_all,@Month_1_NOK,@Quarter_all,@Quarter_NOK,@Quarter_1_all,@Quarter_1_NOK,@Year_all,@Year_NOK,@Year_1_all,@Year_1_NOK,2)

--SELECT *
--FROM Tabx_RS_OTDExternalPBINew

GO

