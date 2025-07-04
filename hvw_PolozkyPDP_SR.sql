USE [RayService]
GO

/****** Object:  View [dbo].[hvw_PolozkyPDP_SR]    Script Date: 04.07.2025 6:55:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_PolozkyPDP_SR] AS SELECT
IdHlavPDP, DIC, Kod, Mnozstvi, MernaJednotka, ZakladDane, DatumDUZP
, IdFaktura, IdDenik, IdPokladna, IdPolPok, IdPohybyZbozi, MnozstviNeZaokr
, ZakladDaneNeZaokr, GUID, GUIDText, Kontrola, ICO, NazevObdobi
FROM TabPolozkyPDP_SR
UNION
SELECT
P.IdHlavPDP, P.DIC, P.Kod, P.Mnozstvi, P.MernaJednotka, P.ZakladDane, P.DatumDUZP
, P.IdFaktura, P.IdDenik, P.IdPokladna, P.IdPolPok, P.IdPohybyZbozi, P.MnozstviNeZaokr
, P.ZakladDaneNeZaokr, P.GUID, P.GUIDText, P.Kontrola, VO.ICO, O.Nazev
FROM TabPolozkyPDP P
JOIN TabHlavickaPDP H ON H.ID=P.IdHlavPDP
LEFT OUTER JOIN TabObdobiDPH O ON O.ID=H.ObdobiDPH
LEFT OUTER JOIN TabCisOrg VO ON VO.CisloOrg=0
GO

