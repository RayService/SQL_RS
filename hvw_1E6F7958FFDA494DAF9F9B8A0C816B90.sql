USE [RayService]
GO

/****** Object:  View [dbo].[hvw_1E6F7958FFDA494DAF9F9B8A0C816B90]    Script Date: 03.07.2025 10:59:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_1E6F7958FFDA494DAF9F9B8A0C816B90] AS SELECT
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
FROM Tabx_RS_PersMzdy_New_Znalostni_rozmer S WITH(NOLOCK)
GO

