USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_PoziceZarazeniZam]    Script Date: 04.07.2025 8:12:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_PoziceZarazeniZam] AS SELECT
ID = IDZam
,IDZam
,Vypocet
,Body_K1
,Body_K2
,Body_K3
,Body_K4
,Splnuje_P8
,Splnuje_P7
,Splnuje_P6
,Splnuje_P5
,Splnuje_P4
,Splnuje_P3
,Splnuje_P2
,Splnuje_P1
,Pozice
,DatPorizeni
,Autor
FROM Tabx_RSPersMzdy_PoziceZarazeniZam
GO

