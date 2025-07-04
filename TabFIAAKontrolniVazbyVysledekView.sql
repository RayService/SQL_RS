USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAAKontrolniVazbyVysledekView]    Script Date: 04.07.2025 10:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAAKontrolniVazbyVysledekView]  --UPDATED 20130316
AS
SELECT 
V.ID, 
V.Chyba,
V.CisloChyby,
DK.TextDruhKontroly1, 
CK.TextKontroly1, 
CK.TextVzorec, 
CK.Poznamka1, 
V.CastkaVlevo,
V.CastkaVpravo,
V.Rozdil,
V.DatumKontroly,
V.Autor,
V.CisloKontroly,
CK.IdKontrVazby,
CK.IdKontroly, 
V.IdSys,
V.IdFIAAObdobiProVykazy,
V.IdFIAAKontrolniVazby,
V.IdVykazVlevo,
V.IdVykazVpravo,
V.Informace,
V.TypZmeny,
V.CisloUctuPAP
FROM TabFIAAKontrolniVazbyVysledek AS V
LEFT OUTER JOIN TabFIAAKontrolniVazbyCisloKontroly AS CK ON CK.CisloKontroly = V.CisloKontroly
LEFT OUTER JOIN TabFIAAKontrolniVazbyDruhKontroly AS DK ON DK.DruhKontroly = CK.DruhKontroly
GO

