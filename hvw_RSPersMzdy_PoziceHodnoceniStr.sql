USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_PoziceHodnoceniStr]    Script Date: 04.07.2025 8:10:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_PoziceHodnoceniStr] AS SELECT
S.ID
,P.Kod
,P.Poradi
,S.Stredisko
,P.Nazev
,S.Hodnoceni_Body
,S.Hodnoceni_U1
,S.Hodnoceni_U2
,S.Hodnoceni_U3
,S.Hodnoceni_U4
,S.DatZmeny
,S.Zmenil
FROM Tabx_RSPersMzdy_PoziceStredisko S
INNER JOIN Tabx_RSPersMzdy_Pozice P ON S.Poradi = P.Poradi
GO

