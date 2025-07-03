USE [RayService]
GO

/****** Object:  View [dbo].[hvw_GadgetsVzor_Pohledavky]    Script Date: 03.07.2025 14:58:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_GadgetsVzor_Pohledavky] AS SELECT
REPLACE(
REPLACE(
CONVERT(NVARCHAR(255), CAST(ISNULL(SUM(Saldo_Ucet),0) AS MONEY), 1)
,',',' '
)
,'.',','
) + ' ' + CASE WHEN (SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1)='CZK' THEN 'Kč' ELSE (SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1) END
AS Pohledavky
FROM dbo.TabSaldo
WHERE CisloSalSk='200'
GO

