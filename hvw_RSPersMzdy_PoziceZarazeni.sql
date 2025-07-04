USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_PoziceZarazeni]    Script Date: 04.07.2025 8:11:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_PoziceZarazeni] AS SELECT
ID
,Kod
,Poradi
,Nazev
,Podminka_K1
,Podminka_K2
,Podminka_K3
,Podminka_K4
,Podminka = CAST(REPLACE(STUFF(
(
CASE WHEN Podminka_K1 IS NOT NULL THEN N';K1' + Podminka_K1 ELSE N'' END
+ CASE WHEN Podminka_K2 IS NOT NULL THEN N';K2' + Podminka_K2 ELSE N'' END
+ CASE WHEN Podminka_K3 IS NOT NULL THEN N';K3' + Podminka_K3 ELSE N'' END
+ CASE WHEN Podminka_K4 IS NOT NULL THEN N';K4' + Podminka_K4 ELSE N'' END
)
,1,1,N''),CHAR(32),N'') as NVARCHAR(255))
,DatZmeny
,Zmenil
FROM Tabx_RSPersMzdy_Pozice
GO

