USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_Vypocet]    Script Date: 04.07.2025 8:14:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_Vypocet] AS SELECT
V.ID
,Vypocteno = CAST(CASE WHEN V.IDPP IS NOT NULL THEN 1 ELSE 0 END as BIT)
,V.IDZam
,V.Vypocet
,V.IDPP
,V.Algoritmus
,V.Pozice
,V.TypMzdy
,V.Mzda
,V.DatPorizeni
,V.Autor
,V.DatZmeny
,V.Zmenil
FROM Tabx_RSPersMzdy_Vypocet V
GO

