USE [RayService]
GO

/****** Object:  View [dbo].[TabFIADataSkladView]    Script Date: 04.07.2025 10:59:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIADataSkladView]  --UPDATED 20140613
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
Z.Nazev1 AS TabKmenZbozi_Nazev1,
Z.Nazev2 AS TabKmenZbozi_Nazev2,
Z.Nazev3 AS TabKmenZbozi_Nazev3,
Z.Nazev4 AS TabKmenZbozi_Nazev4,
Z.SKP AS TabKmenZbozi_SKP,
D.SkupZbo + ' ' + D.Ucet_RegCis AS SkupZboRegCis,
DDZ.Nazev AS TabDruhDokZbo_Nazev,
FIAAVD.Text1 AS TabFIAAVykazDefinice_Text1,
FIAAVD.Text2 AS TabFIAAVykazDefinice_Text2,
FIAAVD.Text3 AS TabFIAAVykazDefinice_Text3,
FIAAVD.Text4 AS TabFIAAVykazDefinice_Text4,
FIAAVD.CisloRadku AS TabFIAAVykazDefinice_CisloRadku,
FIAAVD.Oznaceni AS TabFIAAVykazDefinice_Oznaceni
FROM TabFIAData AS D
LEFT OUTER JOIN TabFIADataParam AS DP ON DP.ID = D.IdFIADataParam
LEFT OUTER JOIN TabObdobi AS Obd ON  Obd.ID = D.IdObdobi
LEFT OUTER JOIN TabFIAObdobiZobrazeni AS ObdZ ON ObdZ.ID = D.IdObdobiZobrazeni
LEFT OUTER JOIN TabCisOrg AS O ON O.CisloOrg = D.CisloOrg
LEFT OUTER JOIN TabStrom AS S ON S.Cislo = D.Utvar
LEFT OUTER JOIN TabZakazka AS Zak ON Zak.CisloZakazky = D.CisloZakazky
LEFT OUTER JOIN TabNakladovyOkruh AS NakO ON NakO.Cislo = D.CisloNakladovyOkruh
LEFT OUTER JOIN TabIVozidlo AS Voz ON Voz.ID = D.IdVozidlo
LEFT OUTER JOIN TabCisZam AS Zam ON Zam.Cislo = D.CisloZam
LEFT OUTER JOIN TabKmenZbozi AS Z ON Z.SkupZbo = D.SkupZbo AND Z.RegCis = D.Ucet_RegCis
LEFT OUTER JOIN TabDruhDokZbo AS DDZ ON DDZ.RadaDokladu = D.Sbornik_RadaDokl AND DDZ.DruhPohybuZbo = D.Strana_DruhPohybuZbo
LEFT OUTER JOIN TabFIAAVykazDefinice AS FIAAVD ON FIAAVD.ID = D.IdFIAAVykazDefinice
WHERE D.Typ = 1 
AND(SUser_SName() IN (SELECT LoginName FROM TabFIAWarrantView WHERE TabFIAWarrantView.IdSkupina=D.IdFIADataParam 
AND(NOT TabFIAWarrantView.ReadOnly=2)AND(TabFIAWarrantView.TableNr=6)))
GO

