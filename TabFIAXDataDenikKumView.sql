USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAXDataDenikKumView]    Script Date: 04.07.2025 10:52:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAXDataDenikKumView]    --UPDATED 20160808 
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
FIAAVD.Text1 AS TabFIAAVykazDefinice_Text1,
FIAAVD.Text2 AS TabFIAAVykazDefinice_Text2,
FIAAVD.Text3 AS TabFIAAVykazDefinice_Text3,
FIAAVD.Text4 AS TabFIAAVykazDefinice_Text4,
FIAAVD.CisloRadku AS TabFIAAVykazDefinice_CisloRadku,
FIAAVD.Oznaceni AS TabFIAAVykazDefinice_Oznaceni,
CUD.NazevUctu AS TabCisUctDef_NazevUctu,
CUD.DruhyNazevUctu AS TabCisUctDef_DruhyNazevUctu,
CUD.DruhyUcet AS TabCisUctDef_DruhyUcet,
DUD.Nazev AS TabSbornik_Nazev
FROM /*SysJmenoDatabase*/.dbo.TabFIADataKum AS D
LEFT OUTER JOIN TabFIADataParam AS DP ON DP.ID = D.IdFIADataParam
LEFT OUTER JOIN TabObdobi AS Obd ON  Obd.ID = D.IdObdobi
LEFT OUTER JOIN TabFIAObdobiZobrazeni AS ObdZ ON ObdZ.ID = D.IdObdobiZobrazeni
LEFT OUTER JOIN TabCisOrg AS O ON O.CisloOrg = D.CisloOrg
LEFT OUTER JOIN TabStrom AS S ON S.Cislo = D.Utvar
LEFT OUTER JOIN TabZakazka AS Zak ON Zak.CisloZakazky = D.CisloZakazky
LEFT OUTER JOIN TabNakladovyOkruh AS NakO ON NakO.Cislo = D.CisloNakladovyOkruh
LEFT OUTER JOIN TabIVozidlo AS Voz ON Voz.ID = D.IdVozidlo
LEFT OUTER JOIN TabCisZam AS Zam ON Zam.Cislo = D.CisloZam
LEFT OUTER JOIN TabFIAAVykazDefinice AS FIAAVD ON FIAAVD.ID = D.IdFIAAVykazDefinice
LEFT OUTER JOIN TabCisUctDef AS CUD ON CUD.CisloUcet = D.Ucet_RegCis AND  CUD.IdObdobi = D.IdObdobi
LEFT OUTER JOIN TabSbornik AS DUD ON DUD.Cislo = D.Sbornik_RadaDokl
 WHERE D.Typ = 2
AND(SUser_SName() COLLATE DATABASE_DEFAULT IN(SELECT LoginName FROM TabFIAWarrantView WHERE TabFIAWarrantView.IdSkupina=D.IdFIADataParam 
AND(NOT TabFIAWarrantView.ReadOnly=2)AND(TabFIAWarrantView.TableNr=6)))
GO

