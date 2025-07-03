USE [RayService]
GO

/****** Object:  View [dbo].[hvw_GadgetSVzor_StavUctu]    Script Date: 03.07.2025 14:59:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_GadgetSVzor_StavUctu] AS SELECT TOP 1
REPLACE(
REPLACE(
CONVERT(NVARCHAR(255), CAST(ISNULL(ZustatekNovy,0) AS MONEY), 1)
,',',' '
)
,'.',','
) + ' ' + CASE WHEN (SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1)='CZK' THEN 'Kč' ELSE (SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1) END
AS StavUctu
FROM dbo.TabBankVypisH
ORDER BY DatumVypisu DESC
GO

