USE [RayService]
GO

/****** Object:  View [dbo].[hvw_2BC42BCDAB5E44089085AA81272754CB]    Script Date: 03.07.2025 11:03:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_2BC42BCDAB5E44089085AA81272754CB] AS SELECT
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
FROM Tabx_RS_PersMzdy_New_Poznavaci_rozmer S WITH(NOLOCK)
GO

