USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_CreateJSONRequestForADD_ContentData]    Script Date: 26.06.2025 14:32:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_CreateJSONRequestForADD_ContentData]
@IdZasilky INT
AS
SET NOCOUNT ON
DECLARE @KodDopravce NVARCHAR(20)
SET @KodDopravce=(SELECT KodDopravce FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)
IF OBJECT_ID('dbo.epx_Balikobot_VratContentDataZasilky', 'P') IS NOT NULL
BEGIN
EXEC dbo.epx_Balikobot_VratContentDataZasilky @IdZasilky=@IdZasilky
RETURN
END
IF @KodDopravce=N'ups'
BEGIN
SELECT  P.Nazev2 AS content_name_en
, P.Hmotnost AS content_weight
, P.Mnozstvi AS content_pieces
, P.JCbezDaniVal AS content_price
, P.Mena AS content_currency
, P.BarCode AS content_ean
, (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg=0) AS content_country
FROM Tabx_BalikobotVZasilkyDoklady VZD
LEFT OUTER JOIN TabDokladyZbozi D ON D.ID=VZD.IdDoklad
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.Id=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
WHERE VZD.IdZasilky=@IdZasilky AND K.Sluzba=0
RETURN
END
IF @KodDopravce=N'pbh'
BEGIN
SELECT  P.Nazev2 AS content_name_en
, P.Nazev3 AS content_name_ua
, P.Hmotnost AS content_weight
, P.Mnozstvi AS content_pieces
, P.JCbezDaniVal AS content_price_eur
, P.BarCode AS content_ean
, P.RegCis AS content_customs_code
, (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg=0) AS content_country
FROM Tabx_BalikobotVZasilkyDoklady VZD
LEFT OUTER JOIN TabDokladyZbozi D ON D.ID=VZD.IdDoklad
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.Id=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
WHERE VZD.IdZasilky=@IdZasilky AND K.Sluzba=0
RETURN
END
IF @KodDopravce=N'zasilkovna'
BEGIN
SELECT  P.Nazev2 AS content_name_en
, P.Nazev3 AS content_name
, P.Hmotnost AS content_weight
, P.Mnozstvi AS content_pieces
, dbo.hfx_Balikobot_VratCastkuContentData(@IdZasilky, P.ID, @KodDopravce, 0) AS content_price_eur
, dbo.hfx_Balikobot_VratCastkuContentData(@IdZasilky, P.ID, @KodDopravce, 1) AS content_price
, P.BarCode AS content_ean
, P.RegCis AS content_customs_code
, (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg=0) AS content_country
, D.ParovaciZnak AS content_invoice_number
, D.DatPovinnostiFa AS content_invoice_issue_date
FROM Tabx_BalikobotVZasilkyDoklady VZD
LEFT OUTER JOIN TabDokladyZbozi D ON D.ID=VZD.IdDoklad
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.Id=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
WHERE VZD.IdZasilky=@IdZasilky AND K.Sluzba=0
RETURN
END
IF @KodDopravce=N'tnt'
BEGIN
SELECT  P.Nazev2 AS content_name_en
, P.Hmotnost AS content_weight
, P.Mnozstvi AS content_pieces
, P.JCbezDaniVal AS content_price
, SUBSTRING(K.Poznamka, 1, 60) AS content_description
, (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg=0) AS content_country
FROM Tabx_BalikobotVZasilkyDoklady VZD
LEFT OUTER JOIN TabDokladyZbozi D ON D.ID=VZD.IdDoklad
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.Id=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
WHERE VZD.IdZasilky=@IdZasilky AND K.Sluzba=0
RETURN
END
IF @KodDopravce=N'japo'
BEGIN
SELECT  P.Nazev2 AS content_name
, P.Hmotnost AS content_weight
, P.Mnozstvi AS content_pieces
, P.JCbezDaniVal AS content_price
, CASE WHEN K.CelniNomenklatura='' THEN NULL
ELSE
SUBSTRING(K.CelniNomenklatura, 1, 4) + N'.' +
SUBSTRING(K.CelniNomenklatura, 5, 2) + N'.' +
SUBSTRING(K.CelniNomenklatura, 7, 2)
END
AS content_customs_code
FROM Tabx_BalikobotVZasilkyDoklady VZD
LEFT OUTER JOIN TabDokladyZbozi D ON D.ID=VZD.IdDoklad
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.Id=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
WHERE VZD.IdZasilky=@IdZasilky AND K.Sluzba=0
RETURN
END
IF @KodDopravce=N'dhl'
BEGIN
SELECT  P.Nazev2 AS content_name
, P.Hmotnost AS content_weight
, P.Mnozstvi AS content_pieces
, P.JCbezDaniVal AS content_price
, CASE WHEN K.CelniNomenklatura='' THEN NULL
ELSE
SUBSTRING(K.CelniNomenklatura, 1, 4) + N'.' +
SUBSTRING(K.CelniNomenklatura, 5, 2) + N'.' +
SUBSTRING(K.CelniNomenklatura, 7, 2)
END
AS content_customs_code
, (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg=0) AS content_country
FROM Tabx_BalikobotVZasilkyDoklady VZD
LEFT OUTER JOIN TabDokladyZbozi D ON D.ID=VZD.IdDoklad
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.Id=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
WHERE VZD.IdZasilky=@IdZasilky AND K.Sluzba=0
RETURN
END
IF @KodDopravce=N'fedex'
BEGIN
SELECT
  P.Hmotnost AS content_weight
, P.Mnozstvi AS content_pieces
, SUBSTRING(K.Poznamka, 1, 60) AS content_description
, P.JCbezDaniVal AS content_price
, (SELECT IdZeme FROM TabCisOrg WHERE CisloOrg=0) AS content_country
, P.Mena AS content_currency
FROM Tabx_BalikobotVZasilkyDoklady VZD
LEFT OUTER JOIN TabDokladyZbozi D ON D.ID=VZD.IdDoklad
LEFT OUTER JOIN TabPohybyZbozi P ON P.IDDoklad=D.ID
LEFT OUTER JOIN TabStavSkladu S ON S.Id=P.IDZboSklad
LEFT OUTER JOIN TabKmenZbozi K ON K.ID=S.IDKmenZbozi
WHERE VZD.IdZasilky=@IdZasilky AND K.Sluzba=0
RETURN
END
GO

