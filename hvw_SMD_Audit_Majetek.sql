USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_Majetek]    Script Date: 04.07.2025 8:32:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_Majetek] AS SELECT TypMaj+'/'+CAST(CisloMaj as NVARCHAR) as CisloMaj,
       Nazev1,
      (SELECT TOP 1  UcetMD FROM TabMaPohU u 
         INNER JOIN TabUKod k ON k.CisloKontace = u.Ukod
         INNER JOIN TabRadekUKod kr ON kr.IDUKod = k.id
         WHERE u.idMaj = m.id AND u.TypPoh = 0) as Ucet,  

       (SELECT Nazev FROM TabStrom WHERE Cislo = (SELECT TOP 1 Utvar FROM TabMaUmis T WHERE T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi)  
	   ORDER BY T.DatumPlatnosti DESC)) as Umisteni,

	   CASE WHEN DatumVyr_X IS NULL THEN 'Ano' ELSE 'Ne' END as Evidovan,

	   DatumZav_X ,
	   DatumVyr_X ,

	   (SELECT TOP 1 RokyOdpisu FROM TabMaPohD  T WHERE T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as RokyOdpisu,

	   (SELECT TOP 1 CenaStav  FROM TabMaPohU  T WHERE T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as PCucetni,

	   (SELECT TOP 1 OpravkyStav  FROM TabMaPohU  T WHERE T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as Uopravky,

	   (SELECT SUM(OpravkyZmena)  FROM TabMaPohU  T WHERE  t.TypPoh = 1 AND T.IdMaj = m.Id AND T.DatumPlatnosti_X  >= (SELECT DatumOd FROM SMDTabVyberObdobi) AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi)) as Uodpisy,

	   (SELECT TOP 1 ZusCenStav FROM TabMaPohU  T WHERE T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as ZCucetni,

	   (SELECT TOP 1 ZusCenStav FROM TabMaPohU  T WHERE t.TypPoh = 8 AND T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as ZCvyrazeniU,

	   (SELECT TOP 1 CASE Skupina
	    WHEN  0 THEN '1.skupina'
        WHEN  1 THEN '1a.skupina'
		WHEN 2 THEN '2.skupina'
		WHEN 3 THEN '3.skupina'
		WHEN 4 THEN '4.skupina'
		WHEN 5 THEN '5.skupina'
		WHEN 6 THEN '6.skupina'
		WHEN 7 THEN '§30 odst. 4 až 6'
		WHEN 8 THEN 'jiná skupina(se sazbou)'
		WHEN 10 THEN '§24 odst. 2 písm v)'
		WHEN 11 THEN '§30 odst. 6'
		WHEN 20 THEN 'audiovizuální dílo'
		WHEN 21 THEN 'software a NVVV'
		WHEN 22 THEN 'zřizovací výdaje'
		WHEN 23 THEN 'ostatní nehmotný majetek'
		WHEN 28 THEN '§30b fotovoltaická zařízení'
		WHEN 29 THEN 'jiná skupina(časová) ' END
	   FROM TabMaPohD  T WHERE T.IdMaj =  m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as DanSkupina,

	   (SELECT TOP 1 CASE Zpusob
		WHEN 0 THEN 'rovnoměrný'
		WHEN 1 THEN 'zrychlený'
		WHEN 8 THEN '§30b fotovoltaická zařízení'
		WHEN 4 THEN '§32a nehmotný majetek'
		WHEN 5 THEN 'stádo'
		WHEN 2 THEN 'jiný způsob(se sazbou)'
		WHEN 3 THEN 'jiný způsob(časový)'
		WHEN 7 THEN 'mimořádný' END
	   FROM TabMaPohD  T WHERE T.IdMaj =  m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as Zpusob,

	   (SELECT TOP 1 VstCenStav  FROM TabMaPohD  T WHERE T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as VstupCenaD,

	   (SELECT TOP 1 OpravkyStav  FROM TabMaPohD  T WHERE T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as Dopravky,

	   (SELECT SUM(OpravkyZmena)  FROM TabMaPohD  T WHERE  t.TypPoh = 1 AND T.IdMaj = m.Id  AND T.DatumPlatnosti_X  >= (SELECT DatumOd FROM SMDTabVyberObdobi)  AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi)) as Dodpisy,

	   (SELECT TOP 1 ZusCenStav FROM TabMaPohD  T WHERE T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as ZCdanova,

	   (SELECT TOP 1 ZusCenStav FROM TabMaPohD  T WHERE t.TypPoh = 8 AND T.IdMaj = m.Id AND T.DatumPlatnosti_X  <= (SELECT DatumDo FROM SMDTabVyberObdobi) ORDER BY t.DatumPlatnosti DESC ) as ZCvyrazeniD


 FROM TabMaKar m  
 WHERE DatumZav_X <= (SELECT DatumDo FROM SMDTabVyberObdobi)
     AND (DatumVyr_X IS NULL OR DatumVyr_X >= (SELECT DatumOd FROM SMDTabVyberObdobi))
     /*AND (DanovePohyby = 1 OR UcetniPohyby = 1)*/
GO

