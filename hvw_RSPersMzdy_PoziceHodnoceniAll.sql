USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_PoziceHodnoceniAll]    Script Date: 04.07.2025 8:10:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_PoziceHodnoceniAll] AS SELECT
Stredisko = NULL
,S.Hodnoceni_Body
,S.Hodnoceni_U1
,S.Hodnoceni_U2
,S.Hodnoceni_U3
,S.Hodnoceni_U4
FROM Tabx_RSPersMzdy_Pozice S
UNION ALL
SELECT
S.Stredisko
,S.Hodnoceni_Body
,S.Hodnoceni_U1
,S.Hodnoceni_U2
,S.Hodnoceni_U3
,S.Hodnoceni_U4
FROM Tabx_RSPersMzdy_PoziceStredisko S
GO

