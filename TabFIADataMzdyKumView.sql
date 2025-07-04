USE [RayService]
GO

/****** Object:  View [dbo].[TabFIADataMzdyKumView]    Script Date: 04.07.2025 10:38:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIADataMzdyKumView]  --UPDATED 20130425
AS 
SELECT
D.*, 
DP.Nazev1 AS TabFIADataParam_Nazev1,
DP.Nazev2 AS TabFIADataParam_Nazev2,
Obd.Nazev AS TabObdobi_Nazev,
Obdz.NazevObdobiZobrazeni AS TabFIAObdobiZobrazeni_NazevObdobiZobrazeni,
Obdz.MesicOd_X AS TabFIAObdobiZobrazeni_MesicOd,
Obdz.MesicDo_X AS TabFIAObdobiZobrazeni_MesicDo,
O.Firma AS TabCisOrg_Firma,
O.ICO AS TabCisOrg_ICO,
S.Nazev AS TabStrom_Nazev,
Zak.Nazev AS TabZakazka_Nazev,
Zak.DruhyNazev AS TabZakazka_DruhyNazev,
NakO.Nazev AS TabNakladovyOkruh_Nazev,
Voz.SPZZobraz AS TabIVozidlo_SPZZobraz,
Voz.Popis AS TabIVozidlo_Popis,
Zam.CisloJmenoTituly AS TabCisZam_CisloJmenoTituly,
Zam.PrijmeniJmeno AS TabCisZam_PrijmeniJmeno,
Zam.Prijmeni AS TabCisZam_Prijmeni,
Zam.Jmeno AS TabCisZam_Jmeno,
Zam.Alias AS TabCisZam_Alias,
CMS.NazevMS AS TabCisMzSl_NazevMS,
CMS.NazevMS2 AS TabCisMzSl_NazevMS2,
SMS.Nazev AS TabSkupMS_Nazev
FROM TabFIADataKum AS D
LEFT OUTER JOIN TabFIADataParam AS DP ON DP.ID = D.IdFIADataParam
LEFT OUTER JOIN TabObdobi AS Obd ON  Obd.ID = D.IdObdobi
LEFT OUTER JOIN TabFIAObdobiZobrazeni AS ObdZ ON ObdZ.ID = D.IdObdobiZobrazeni
LEFT OUTER JOIN TabCisOrg AS O ON O.CisloOrg = D.CisloOrg
LEFT OUTER JOIN TabStrom AS S ON S.Cislo = D.Utvar
LEFT OUTER JOIN TabZakazka AS Zak ON Zak.CisloZakazky = D.CisloZakazky
LEFT OUTER JOIN TabNakladovyOkruh AS NakO ON NakO.Cislo = D.CisloNakladovyOkruh
LEFT OUTER JOIN TabIVozidlo AS Voz ON Voz.ID = D.IdVozidlo
LEFT OUTER JOIN TabCisZam AS Zam ON Zam.Cislo = D.CisloZam
LEFT OUTER JOIN TabMzdObd AS MO ON MO.MzdObd_DatumDo = D.Datum_X
LEFT OUTER JOIN TabCisMzSl AS CMS ON CMS.CisloMzSl = D.Ucet_RegCis AND CMS.IdObdobi = MO.IdObdobi
LEFT OUTER JOIN TabSkupMS AS SMS ON SMS.SkupinaMS=CMS.SkupinaMS AND SMS.IdObdobi=MO.IdObdobi
 WHERE D.Typ = 4
AND(SUser_SName()IN(SELECT LoginName FROM TabFIAWarrantView WHERE TabFIAWarrantView.IdSkupina=D.IdFIADataParam 
AND(NOT TabFIAWarrantView.ReadOnly=2)AND(TabFIAWarrantView.TableNr=6)))
GO

