USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_PoziceZarazeniZamTK]    Script Date: 04.07.2025 8:13:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_PoziceZarazeniZamTK] AS SELECT
ID = IDZam
,IDZam
,Vypocet
,TK_Mzda_Hodinova
,TK_Mzda_K1
,TK_Mzda_K2
,TK_Mzda_K3
,TK_HodnotaBodu
,Pozice
,DatPorizeni
,Autor
FROM Tabx_RSPersMzdy_PoziceZarazeniZam
GO

