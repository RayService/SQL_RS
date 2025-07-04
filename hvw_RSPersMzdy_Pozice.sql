USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_Pozice]    Script Date: 04.07.2025 8:08:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_Pozice] AS SELECT
ID
,Kod
,Poradi
,Nazev
,TK_Od
,TK_Do
,THP_MzdaFix
,THP_MzdaPohyb
,THP_MzdaOdmena
,TPV_KS
,TPV_EL
,TPV_MD
,DatZmeny
,Zmenil
FROM Tabx_RSPersMzdy_Pozice
GO

