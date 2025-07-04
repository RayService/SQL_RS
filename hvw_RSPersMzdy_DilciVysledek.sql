USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_DilciVysledek]    Script Date: 04.07.2025 8:07:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_DilciVysledek] AS SELECT
ID
,IDZam
,Vypocet
,Kategorie
,Uroven
,PP_Vysledek
,Z_Vysledek
,Vysledek
FROM Tabx_RSPersMzdy_DilciVysledek
GO

