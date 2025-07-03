USE [RayService]
GO

/****** Object:  View [dbo].[hvw_GadgetsVzor_Fakturace]    Script Date: 03.07.2025 14:56:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_GadgetsVzor_Fakturace] AS SELECT
REPLACE(
REPLACE(
CONVERT(NVARCHAR(255), CAST(ISNULL(SUM(FaV.SumaKcBezDPHDruh),0) AS Money), 1)
,',',' '
)
,'.',','
) + ' ' + CASE WHEN (SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1)='CZK' THEN 'Kč' ELSE (SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1) END
AS Fakturace
FROM dbo.TabDokladyZbozi FaV
WHERE ((FaV.DruhPohybuZbo=13) OR (FaV.DruhPohybuZbo=14)) AND (FaV.DUZP_Y=DATEPART(year,GETDATE())) AND (FaV.DUZP_M=DATEPART(month,GETDATE()))
GO

