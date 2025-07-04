USE [RayService]
GO

/****** Object:  View [dbo].[TabDodZboView]    Script Date: 04.07.2025 9:52:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabDodZboView] AS
SELECT M.IDCisOrg, M.CisloOrg, ISNULL(M.IDKmenZbozi,0) AS IDKmenZbozi, M.IDSklad, M.IDNC,
M.AktDodavatel, M.MinimumDod, M.MinimumBalDod, M.DodaciLhuta, M.TypDodLhuty,
ISNULL((SUBSTRING(REPLACE(SUBSTRING(M.Poznamka,1,255),
(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)),'') AS Poznamka,
(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,
(CASE M.TypDodLhuty
WHEN 0 THEN DateAdd(Day,   M.DodaciLhuta, GetDate())
WHEN 1 THEN DateAdd(Month, M.DodaciLhuta, GetDate())
WHEN 2 THEN DateAdd(Year,  M.DodaciLhuta, GetDate()) END))))) AS DatDodani
FROM (
SELECT X.ID AS IDCisOrg, X.CisloOrg, X.KID AS IDKmenZbozi,
S.IDSklad, C.ID AS IDNC, D.Poznamka,
CAST(
CASE WHEN K.Aktualni_Dodavatel = X.CisloOrg
THEN 1 ELSE 0 END AS BIT) AS AktDodavatel,
CASE WHEN K.Aktualni_Dodavatel = X.CisloOrg
THEN K.Minimum_Dodavatel ELSE D.Minimum_Dodavatel END AS MinimumDod,
CASE WHEN K.Aktualni_Dodavatel = X.CisloOrg
THEN K.Minimum_Baleni_Dodavatel ELSE D.Minimum_Baleni_Dodavatel END AS MinimumBalDod,
CASE WHEN K.Aktualni_Dodavatel = X.CisloOrg
THEN K.DodaciLhuta ELSE D.DodaciLhuta END AS DodaciLhuta,
CASE WHEN K.Aktualni_Dodavatel = X.CisloOrg
THEN K.TypDodaciLhuty ELSE D.TypDodaciLhuty END AS TypDodLhuty
FROM(
SELECT O.ID, O.CisloOrg, O.CenovaUrovenNakup, K.ID AS KID
FROM TabCisOrg    AS O
JOIN TabKmenZbozi AS K ON K.Aktualni_Dodavatel = O.CisloOrg
UNION
SELECT O.ID, O.CisloOrg, O.CenovaUrovenNakup, D.IDKmenZbozi
FROM TabCisOrg         AS O
JOIN TabZboziDodavatel AS D ON D.IDCisOrg = O.ID) AS X
JOIN TabKmenZbozi                 AS K ON K.ID = X.KID
JOIN TabStavSkladu                AS S ON S.IDKmenZbozi = K.ID
LEFT OUTER JOIN TabZboziDodavatel AS D ON D.IDKmenZbozi = X.KID AND D.IDCisOrg = X.ID
LEFT OUTER JOIN TabNC AS C ON C.CenovaUroven = X.CenovaUrovenNakup
AND ((((SELECT PlatnostNabCen FROM TabHGlob) = 0) AND (C.IDZboSklad  = S.ID)) OR
(((SELECT PlatnostNabCen FROM TabHGlob) = 1) AND (C.IDKmenZbozi = X.KID)))) AS M
GO

