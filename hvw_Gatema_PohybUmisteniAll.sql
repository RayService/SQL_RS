USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Gatema_PohybUmisteniAll]    Script Date: 03.07.2025 15:08:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Gatema_PohybUmisteniAll] AS SELECT PU.ID, ManJed=convert(bit,0), IDPohybManJed=NULL, IDNadManJed=NULL, IDManJed=NULL, IDManJedPol=NULL, PU.IDStavSkladu, PU.IDKmenzbozi, PU.IDVyrCis, 
       PU.IDUmisteni, PU.DruhPohybu, PU.Mnozstvi, PU.IDPohZbo, PU.IDSDScanData, PU.Autor, PU.DatPorizeni 
  FROM Gatema_PohybUmisteni PU 
UNION ALL 
SELECT ID=-PMJOZ.ID, ManJed=convert(bit,1), PMJOZ.IDPohybManJed, PMJOZ.IDNadManJed, PMJOZ.IDManJed, PMJOZ.IDManJedPol, PMJOZ.IDStavSkladu, PMJOZ.IDKmenzbozi, PMJOZ.IDVyrCis, 
       IDUmisteni=NULL, PMJ.DruhPohybu, Mnozstvi=CASE WHEN PMJ.DruhPohybu=2 THEN -PMJOZ.Mnozstvi ELSE PMJOZ.Mnozstvi END, PMJOZ.IDPohZbo, PMJOZ.IDSDScanData, PMJ.Autor, PMJ.DatPorizeni 
  FROM Gatema_PohybManJedPolOZ PMJOZ 
    INNER JOIN Gatema_PohybManJed PMJ WITH (READUNCOMMITTED) ON (PMJ.ID=PMJOZ.IDPohybManJed) 
GO

