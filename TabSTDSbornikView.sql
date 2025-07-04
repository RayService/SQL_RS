USE [RayService]
GO

/****** Object:  View [dbo].[TabSTDSbornikView]    Script Date: 04.07.2025 12:56:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabSTDSbornikView]  -- UPDATED 20071010
AS 
SELECT 
S.ID AS ID, 
S.Cislo, 
S.Nazev, 
CAST(1 AS BIT) AS Neprenaset, 
SS.IdObdobiVykazu,
OV.NazevObdobi,
OV.MRObdobi,
OV.ObdobiOd,
OV.ObdobiDo
FROM TabSTDSbornik AS SS
LEFT OUTER JOIN TabSbornik AS S ON SS.CisloSbornik=S.Cislo
LEFT OUTER JOIN TabSTDObdobiVykazu AS OV ON OV.ID=SS.IdObdobiVykazu 
WHERE SS.IdObdobiVykazu = (SELECT TOP 1 IdObdobiVykazu  FROM TabSTDParam WHERE TabSTDParam.Cislo = 1)
UNION 
SELECT 
ID, 
Cislo, 
Nazev, 
CAST(0 AS BIT) AS Neprenaset, 
NULL AS IdObdobiVykazu,
NULL AS NazevObdobi,
NULL AS MRObdobi,
NULL AS DatumOd,
NULL AS DatumDo  
FROM TabSbornik 
WHERE TabSbornik.Cislo NOT IN 
(SELECT CisloSbornik FROM TabSTDSbornik WHERE TabSTDSbornik.IdObdobiVykazu = 
(SELECT TOP 1 IdObdobiVykazu  FROM TabSTDParam WHERE TabSTDParam.Cislo = 1))

 
GO

