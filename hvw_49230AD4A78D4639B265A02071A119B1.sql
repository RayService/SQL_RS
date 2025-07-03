USE [RayService]
GO

/****** Object:  View [dbo].[hvw_49230AD4A78D4639B265A02071A119B1]    Script Date: 03.07.2025 11:08:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_49230AD4A78D4639B265A02071A119B1] AS SELECT
TabStrukKusovnik_kalk_cenik.ID,
TabStrukKusovnik_kalk_cenik.IDNizsi,
TabStrukKusovnik_kalk_cenik.IDZakazka,
VStrukKusovnikKmenZboziNizsi.skupzbo,
VStrukKusovnikKmenZboziNizsi.regcis,
VStrukKusovnikKmenZboziNizsi.nazev1,
TabStrukKusovnik_kalk_cenik.mnf,
VStrukKusovnikKmenZboziNizsi.MJEvidence,
TabStrukKusovnik_kalk_cenik.Vypocteny_prumer,
TabStrukKusovnik_kalk_cenik.Cena_2,
TabStrukKusovnik_kalk_cenik.Cena_dilec,
TabStrukKusovnik_kalk_cenik.Cena_vypoctena,
TabStrukKusovnik_kalk_cenik.Autor,
TabStrukKusovnik_kalk_cenik.Dat_vypoctu,
TabStrukKusovnik_kalk_cenik.dilec,
TabStrukKusovnik_kalk_cenik.material,
TabStrukKusovnik_kalk_cenik.generovany_polozky,
TabStrukKusovnik_kalk_cenik.generovana_poptavka,
TabStrukKusovnik_kalk_cenik.Poznamka,
TabStrukKusovnik_kalk_cenik.Poznamka_dokl,
TabStrukKusovnik_kalk_cenik.OrgNabidka,
TabStrukKusovnik_kalk_cenik.OrgNabidka2,
TabStrukKusovnik_kalk_cenik.OrgNabidka3,
TabStrukKusovnik_kalk_cenik.Cena_doklad,
TabStrukKusovnik_kalk_cenik.Cena_vypoctena_original,
(SUBSTRING(REPLACE(SUBSTRING(TabStrukKusovnik_kalk_cenik.Poznamka,1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS Poznamka_255,
TabStrukKusovnik_kalk_cenik.Poznamka AS Poznamka_ALL,
(SUBSTRING(REPLACE(SUBSTRING(TabStrukKusovnik_kalk_cenik.Poznamka_dokl,1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS Poznamka_dokl_255,
TabStrukKusovnik_kalk_cenik.Poznamka_dokl AS Poznamka_dokl_ALL,
TabStrukKusovnik_kalk_cenik.Dokl_poptMOQ,
TabStrukKusovnik_kalk_cenik.Dokl_poptLT,
TabStrukKusovnik_kalk_cenik.Termin_naceneni,
TabStrukKusovnik_kalk_cenik.OPN_kalk,
TabStrukKusovnik_kalk_cenik.koop_kalk,
TabStrukKusovnik_kalk_cenik.VD,
TabStrukKusovnik_kalk_cenik.CenaOdhadem AS CenaOdhadem,
TabStrukKusovnik_kalk_cenik.CostDriver AS CostDriver,
CASE WHEN TabStrukKusovnik_kalk_cenik.Vypocteny_prumer>0.1 THEN TabStrukKusovnik_kalk_cenik.Cena_vypoctena/TabStrukKusovnik_kalk_cenik.Vypocteny_prumer ELSE NULL END AS PrirazMaterialu,
tco.CisloOrg
FROM TabStrukKusovnik_kalk_cenik WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi VStrukKusovnikKmenZboziNizsi WITH(NOLOCK) ON TabStrukKusovnik_kalk_cenik.IDNizsi=VStrukKusovnikKmenZboziNizsi.ID
LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.CisloOrg = VStrukKusovnikKmenZboziNizsi.Vyrobce
GO

