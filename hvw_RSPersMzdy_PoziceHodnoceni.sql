USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_PoziceHodnoceni]    Script Date: 04.07.2025 8:09:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_PoziceHodnoceni] AS SELECT
ID
,Kod
,Poradi
,Nazev
,Hodnoceni_Body
,Hodnoceni_U1
,Hodnoceni_U2
,Hodnoceni_U3
,Hodnoceni_U4
,DatZmeny
,Zmenil
FROM Tabx_RSPersMzdy_Pozice
GO

