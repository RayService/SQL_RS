USE [RayService]
GO

/****** Object:  View [dbo].[hvw_VlastniFirmaTisk]    Script Date: 04.07.2025 9:16:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_VlastniFirmaTisk] AS SELECT 
o.CisloOrg
,o.Firma
,o.Nazev
,o.DruhyNazev
,o.UliceSCisly AS Ulice
,o.UliceSCisly
,o.Ulice AS UliceBezCisel
,o.PopCislo
,o.OrCislo
,o.Misto
,o.PSC
,o.PoBox
,o.Kontakt
,o.ICO
,o.DIC
,o.Poznamka
,ISNULL(NULLIF(o.UdajOZapisuDoObchRej,N''),o.PostAddress) AS UdajOZapisuDoObchRej
,o.DICsk
,o.PravniForma
,o.IdZeme AS ISOKodZeme
,TabZeme.Nazev AS NazevZeme
,TabZeme.NazevDE AS NazevZemeDE
,UPPER(o.Firma) AS UpperFirma
,UPPER(o.Nazev) AS UpperNazev
,UPPER(o.DruhyNazev) AS UpperDruhyNazev
,UPPER(o.UliceSCisly) AS UpperUliceSCisly
,UPPER(o.Ulice) AS UpperUliceBezCisel
,UPPER(o.Misto) AS UpperMisto
,PevnaLinka.Spojeni AS PevnaLinka
,Mobil.Spojeni AS Mobil
,Fax.Spojeni AS Fax
,E_mail.Spojeni AS E_mail
,WWW.Spojeni AS WWW 
FROM TabCisOrg o 
LEFT JOIN TabZeme ON TabZeme.ISOKod=o.IdZeme 
LEFT OUTER JOIN TabKontakty PevnaLinka ON (o.ID=PevnaLinka.IDOrg AND PevnaLinka.Prednastaveno=1 AND PevnaLinka.IDVztahKOsOrg IS NULL AND PevnaLinka.Druh = 1) 
LEFT OUTER JOIN TabKontakty Mobil      ON (o.ID=Mobil.IDOrg AND Mobil.Prednastaveno=1 AND Mobil.IDVztahKOsOrg IS NULL AND Mobil.Druh = 2) 
LEFT OUTER JOIN TabKontakty Fax        ON (o.ID=Fax.IDOrg AND Fax.Prednastaveno=1 AND Fax.IDVztahKOsOrg IS NULL AND Fax.Druh = 3) 
LEFT OUTER JOIN TabKontakty E_mail     ON (o.ID=E_mail.IDOrg AND E_mail.Prednastaveno=1 AND E_mail.IDVztahKOsOrg IS NULL AND E_mail.Druh = 6) 
LEFT OUTER JOIN TabKontakty WWW        ON (o.ID=WWW.IDOrg AND WWW.Prednastaveno=1 AND WWW.IDVztahKOsOrg IS NULL AND WWW.Druh = 7)
GO

