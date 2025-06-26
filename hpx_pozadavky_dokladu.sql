USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_pozadavky_dokladu]    Script Date: 26.06.2025 12:34:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_pozadavky_dokladu]
AS 
SET NOCOUNT ON

--DELETE TabPozaZDok_kalk
EXEC hpx_GenerovaniPozadavkuZDokladu_kalk
 @Sklad = N'200',
 @Oblast_Rez = 0,
 @Oblast_EP = 1,
 @Oblast_Obj = 0,
 @Oblast_DosObj = 0,
 @Oblast_NabSes = 1,
 @Oblast_Kontr = 0,
 @Oblast_Odv = 0, 
 @RespPredbPlan = 0,
 @RespPlan = 0,
 @RespPrikaz = 0,
 @RespSklad = 0,
 @RespVedProd = 0 
/*
SELECT
TabPozaZDok_kalk.ID,TabPozaZDok_kalk.IDDoklad,TabPozaZDok_kalk.IDPohyb,TabPozaZDok_kalk.IDPohyb_Pom,TabPozaZDok_kalk.IDOdvolavky,TabPozaZDok_kalk.IDTermOdvolavky,TabPozaZDok_kalk.IDZboSklad,TabPozaZDok_kalk.IDKmenZbozi,TabPozaZDok_kalk.IDZakazModif,TabPozaZDok_kalk.IDZakazka,TabPozaZDok_kalk.Oblast,VPozaZDokKmenZbozi.skupZbo,VPozaZDokKmenZbozi.RegCis,VPozaZDokKmenZbozi.Nazev1,VPozaZDokZakazModif.kod,TabPozaZDok_kalk.Mnozstvi,TabPozaZDok_kalk.termin,VPozaZDokTermOdv.IntervalDodani,TabPozaZDok_kalk.mnoz_ZadVyp,TabPozaZDok_kalk.mnoz_Plan,TabPozaZDok_kalk.mnoz_Prikaz,TabPozaZDok_kalk.mnoz_VedProd,TabPozaZDok_kalk.mnoz_sklad,TabPozaZDok_kalk.Pozadavek
FROM TabPozaZDok_kalk
  LEFT OUTER JOIN TabKmenZbozi VPozaZDokKmenZbozi ON VPozaZDokKmenZbozi.ID=TabPozaZDok_kalk.IDKmenZbozi
  LEFT OUTER JOIN TabZakazModif VPozaZDokZakazModif ON VPozaZDokZakazModif.ID=TabPozaZDok_kalk.IDZakazModif
  LEFT OUTER JOIN TabTermOdvolavky VPozaZDokTermOdv ON VPozaZDokTermOdv.ID=TabPozaZDok_kalk.IDTermOdvolavky
  LEFT OUTER JOIN TabPohybyZbozi VPozaZDokPohyb ON VPozaZDokPohyb.ID=TabPozaZDok_kalk.IDPohyb
WHERE
(TabPozaZDok_kalk.Pozadavek>0.0)
*/
GO

