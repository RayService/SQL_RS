USE [RayService]
GO

/****** Object:  View [dbo].[hvw_9100B808A2064CA994329B7898E0DC2E]    Script Date: 03.07.2025 12:41:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_9100B808A2064CA994329B7898E0DC2E] AS SELECT
pozdok.ID,
pozdok.IDDoklad,
pozdok.IDPohyb,
pozdok.IDPohyb_Pom,
pozdok.IDZboSklad,
pozdok.IDKmenZbozi,
pozdok.IDZakazka,
pozdok.Oblast,
tkz.skupZbo,
tkz.RegCis,
tkz.Nazev1,
pozdok.Mnozstvi,
pozdok.termin,
pozdok.mnoz_ZadVyp,
pozdok.mnoz_Plan,
pozdok.mnoz_Prikaz,
pozdok.mnoz_VedProd,
pozdok.mnoz_sklad,
pozdok.Pozadavek,
pozdok.Autor,
pozdok.DatPorizeni,
pozdok.Zmenil,
pozdok.DatZmeny,
pozdok.Poznamka,
(SUBSTRING(REPLACE(SUBSTRING(pozdok.[Poznamka],1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) AS Poznamka_255,
pozdok.Poznamka AS Poznamka_All,
pozdok.NRC_QA,
pozdok.NRC_technology,
pozdok.NRC_engineering,
pozdok.MOQ_costs,
pozdok.FAIR,
pozdok.FORM1,
pozdok.PPAP,
pozdok.LT_firstpiece,
pozdok.LT_serie,
pozdok.Cilova_cena_Kc,
pozdok.Cilova_cena_Val,
pozdok.PolozkyMZ,
(SUBSTRING(REPLACE(SUBSTRING(pozdok.[PolozkyMZ],1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) AS PolozkyMZ_255,
pozdok.Kontroloval,
pozdok.VypocetFairPpap,
pozdok.CofC3_1,
pozdok.KalkulovatFAIR,
pozdok.KalkulovatPPAP,
pozdok.KalkulovatCofC,
pozdok.CisloTarifuKalk,
pozdok.Davka AS Davka
FROM TabPozaZDok_kalk pozdok WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=pozdok.IDKmenZbozi
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=pozdok.IDPohyb
WHERE
(pozdok.Pozadavek>0.0 AND tkz.Dilec = 1)
GO

