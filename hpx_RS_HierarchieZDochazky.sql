USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HierarchieZDochazky]    Script Date: 26.06.2025 13:58:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_HierarchieZDochazky]
AS
BEGIN

DECLARE @IDObdobi INT

SET @IDObdobi=(SELECT CASE WHEN (SELECT DATEPART(MONTH,GETDATE()))=1 THEN (SELECT ID FROM TabMzdObd WHERE Mesic=12 AND Rok=DATEPART(YEAR,GETDATE())-1) 
ELSE (SELECT ID FROM TabMzdObd WHERE Mesic=DATEPART(MONTH,GETDATE())-1 AND Rok=DATEPART(YEAR,GETDATE())) END)

DELETE FROM Tabx_RS_HierarchieZDochazky

INSERT INTO Tabx_RS_HierarchieZDochazky (IDZam,NadrizenyID, DruhMzdyMesHod)
SELECT tcz.ID, tczNad.ID, mzd.DruhMzdyMesHod
--os.osoIDOsoba, os.osoPrijmeni, tcz.Prijmeni, tcz.ID, osv.ov_IDOsoba, osv.ov_IDOsobaVztah, osv.ov_CisloVztahu, osvz.ovzIDOsobaVztahZarazeni, osvz.ovzIDOsobaVztah, osvz.ovzIDOsobaVztah_Vedouci, osvz.ovzPlatnostOd, osvz.ovzPlatnostDo, osN.osoPrijmeni, tczN.Prijmeni, tczN.ID
FROM DOCHAZKASQL.DC3.dbo.Osoba os WITH(NOLOCK)
LEFT OUTER JOIN DOCHAZKASQL.DC3.dbo.OsobaVztah osv WITH(NOLOCK) ON osv.ov_IDZakaznik=os.osoIDZakaznik AND osv.ov_IDOsoba=os.osoIDOsoba
LEFT OUTER JOIN RayService.dbo.TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=ISNULL(osv.ov_CisloVztahu, os.osoOsobniCislo)
LEFT OUTER JOIN DOCHAZKASQL.DC3.dbo.OsobaVztahZarazeni osvz WITH(NOLOCK) ON osvz.ovzIDOsobaVztah=osv.ov_IDOsobaVztah-- AND osvz.ovzPlatnostDo IS NULL
LEFT OUTER JOIN DOCHAZKASQL.DC3.dbo.Osoba osN WITH(NOLOCK) ON osN.osoIDOsoba=osvz.ovzIDOsobaVztah_Vedouci
LEFT OUTER JOIN DOCHAZKASQL.DC3.dbo.OsobaVztah osvN WITH(NOLOCK) ON osvN.ov_IDZakaznik=osN.osoIDZakaznik AND osvN.ov_IDOsoba=osN.osoIDOsoba
LEFT OUTER JOIN RayService.dbo.TabCisZam tczNad WITH(NOLOCK) ON tczNad.Cislo=ISNULL(osvN.ov_CisloVztahu, osN.osoOsobniCislo)
LEFT OUTER JOIN RayService.dbo.TabZamMzd mzd WITH(NOLOCK) ON mzd.ZamestnanecId=tcz.ID AND mzd.IdObdobi=@IDObdobi
WHERE --osN.osoPrijmeni=N'jurčíková' AND
osv.ov_PlatnostDo IS NULL	--ukončení PP nebo docházky
AND osvz.ovzPlatnostDo IS NULL	--ukončení vztahu (přechod na jiného nadřízeného)
AND tcz.ID IS NOT NULL
AND tczNad.ID IS NOT NULL
--os.osoPrijmeni=N'jurčíková' OR os.osoPrijmeni=N'jurasová'
AND tcz.Cislo < 800000
AND (((CASE
WHEN EXISTS(SELECT * FROM TabZamMzd WITH(NOLOCK) WHERE ZamestnanecId=tcz.ID)
THEN
CASE
--MŽ 6.5.2025 změna dohledání období z aktuálního na předchozí
WHEN EXISTS(SELECT * FROM TabZamMzd WITH(NOLOCK) WHERE IdObdobi=@IDObdobi/*(SELECT o.ID FROM TabMzdObd o WITH(NOLOCK) WHERE o.Rok=DATEPART(YEAR,GETDATE()) AND o.Mesic=DATEPART(MONTH,GETDATE()))*/ AND ZamestnanecId=tcz.ID)
--MŽ 6.5.2025 změna dohledání období z aktuálního na předchozí
THEN (SELECT StavES FROM TabZamMzd WITH(NOLOCK) WHERE IdObdobi=@IDObdobi/*(SELECT o.ID FROM TabMzdObd o WITH(NOLOCK) WHERE o.Rok=DATEPART(YEAR,GETDATE()) AND o.Mesic=DATEPART(MONTH,GETDATE()))*/ AND ZamestnanecId=tcz.ID)
WHEN EXISTS(SELECT m.*
FROM TabZamMzd m WITH(NOLOCK)
JOIN TabMzdObd o1 WITH(NOLOCK) ON o1.IdObdobi=m.IdObdobi
--MŽ 6.5.2025 změna dohledání období z aktuálního na předchozí
LEFT OUTER JOIN TabMzdObd o2 WITH(NOLOCK) ON o2.IdObdobi=@IDObdobi/*(SELECT o.ID FROM TabMzdObd o WITH(NOLOCK) WHERE o.Rok=DATEPART(YEAR,GETDATE()) AND o.Mesic=DATEPART(MONTH,GETDATE()))*/
WHERE ((o1.Rok<o2.Rok) OR ((o1.Rok=o2.Rok) AND (o1.Mesic<o2.Mesic))) AND m.ZamestnanecId=tcz.ID)
THEN 4
ELSE 10
END
ELSE
CASE
WHEN EXISTS(SELECT * FROM TabMzNastupPP WITH(NOLOCK) WHERE ZamestnanecId=tcz.ID)
THEN 5
ELSE 6
END
END)) IN (0,5))
ORDER BY osN.osoIDOsoba ASC,os.osoIDOsoba ASC

--oprava Kolíska na Ševčíkovou
UPDATE h SET h.NadrizenyID=4076
FROM Tabx_RS_HierarchieZDochazky h
WHERE h.NadrizenyID=4090


END
GO

