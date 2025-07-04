USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_SouladDovednosti]    Script Date: 04.07.2025 8:13:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_SouladDovednosti] AS SELECT
S.ID
,S.IDZam
,S.Vypocet
,S.Algoritmus
,S.IDPP
,S.Soulad
,S.PP_Kat
,S.PP_KatID
,S.PP_KatNazev
,S.PP_DovednostID
,S.PP_DovednostNazev
,S.PP_Uroven
,S.PP_UrovenID
,S.PP_Priorita
,S.Z_KatID
,S.Z_KatNazev
,S.Z_DovednostID
,S.Z_DovednostNazev
,S.Z_Uroven
,S.Z_UrovenID
,S.Rn_Kat
,S.Rn_KatUroven
,S.DatPorizeni
,S.Autor
FROM Tabx_RSPersMzdy_SouladDovednosti S
GO

