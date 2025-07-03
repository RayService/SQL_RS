USE [RayService]
GO

/****** Object:  View [dbo].[hvw_D77C306FD4B247A59EB3FB6950AC5930]    Script Date: 03.07.2025 14:33:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_D77C306FD4B247A59EB3FB6950AC5930] AS SELECT
TabKusovnik_polozky.ID,TabKusovnik_polozky.IDFinal,TabKusovnik_polozky.IDKmenZbozi,TabKusovnik_polozky.IDZadani,TabKusovnik_polozky.IDZakazka,TabKusovnik_polozky.Sklad,TabKusovnik_polozky.Skupina,TabKusovnik_polozky.Final,VKusovnikKmenZbozi.skupzbo,VKusovnikKmenZbozi.regcis,VKusovnikKmenZbozi.nazev1,TabKusovnik_polozky.mnf,VKusovnikKmenZbozi.MJEvidence,VKusovnikKmenZbozi.CisloZbozi
FROM TabKusovnik_polozky WITH(NOLOCK)
  LEFT OUTER JOIN TabKmenZbozi VKusovnikKmenZbozi WITH(NOLOCK) ON TabKusovnik_polozky.IDKmenZbozi=VKusovnikKmenZbozi.ID
WHERE
(TabKusovnik_polozky.autor = SUSER_SNAME())
GO

