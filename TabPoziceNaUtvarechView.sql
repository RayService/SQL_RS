USE [RayService]
GO

/****** Object:  View [dbo].[TabPoziceNaUtvarechView]    Script Date: 04.07.2025 12:33:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPoziceNaUtvarechView] AS
SELECT DISTINCT --potřebuju kombinace aby tam byly jenom jednou
VPracPoziceAktCisZam.ID AS ID_PracPoz,
VCisZamUtvar.Id AS ID_Utvar,
VCisZamUtvar.Cislo AS Cislo_Utvar,
VPracPoziceAktCisZam.Nazev AS Nazev
FROM TabCisZam cz
LEFT OUTER JOIN TabPracovniPozice VPracPoziceAktCisZam ON EXISTS(SELECT*FROM TabObsazeniPracovnichPozic
WHERE VPracPoziceAktCisZam.ID=IDPP AND PlatnostOd <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))) AND
(PlatnostDo >= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))) OR PlatnostDo IS NULL) AND
IDZam=cz.ID)
LEFT OUTER JOIN TabStrom VCisZamUtvar ON cz.Stredisko=VCisZamUtvar.Cislo
LEFT OUTER JOIN TabKontakty VZamModem ON cz.ID=VZamModem.IDCisZam AND VZamModem.Prednastaveno=1 AND VZamModem.Druh = 2
WHERE (cz.IdObdobi<=(SELECT IdObdobi FROM TabMzdObd WHERE Stav = 1))AND(((CASE WHEN EXISTS(SELECT * FROM TabZamMzd WHERE ZamestnanecId=cz.ID) THEN
CASE WHEN EXISTS(SELECT * FROM TabZamMzd WHERE IdObdobi=(SELECT IdObdobi FROM TabMzdObd WHERE Stav = 1) AND ZamestnanecId=cz.ID) THEN
(SELECT StavES FROM TabZamMzd WHERE IdObdobi=(SELECT IdObdobi FROM TabMzdObd WHERE Stav = 1) AND ZamestnanecId=cz.ID)
WHEN EXISTS(SELECT m.* FROM TabZamMzd m JOIN TabMzdObd o1 ON o1.IdObdobi=m.IdObdobi
LEFT OUTER JOIN TabMzdObd o2 ON o2.IdObdobi=(SELECT IdObdobi FROM TabMzdObd WHERE Stav = 1)
WHERE ((o1.Rok<o2.Rok) OR ((o1.Rok=o2.Rok) AND (o1.Mesic<o2.Mesic))) AND m.ZamestnanecId=cz.ID)
THEN 4
ELSE 10
END
ELSE
CASE WHEN EXISTS(SELECT * FROM TabMzNastupPP WHERE ZamestnanecId=cz.ID) THEN 5 ELSE 6 END
END))<>5)
AND VPracPoziceAktCisZam.ID IS NOT NULL
GO

