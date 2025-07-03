USE [RayService]
GO

/****** Object:  View [dbo].[hvw_GadgetsVzor_FinStavSkl]    Script Date: 03.07.2025 14:58:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_GadgetsVzor_FinStavSkl] AS SELECT
REPLACE(
REPLACE(
CONVERT(NVARCHAR(255), CAST(ISNULL(SUM(StavSkladu),0) AS MONEY),1)
,',',' '
)
,'.',','
) + ' ' + CASE WHEN (SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1)='CZK' THEN 'Kč' ELSE (SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1) END
AS FinStav
FROM dbo.TabStavSkladu
WHERE StavSkladu<>0
GO

