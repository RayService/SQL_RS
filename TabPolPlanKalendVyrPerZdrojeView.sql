USE [RayService]
GO

/****** Object:  View [dbo].[TabPolPlanKalendVyrPerZdrojeView]    Script Date: 04.07.2025 12:32:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPolPlanKalendVyrPerZdrojeView] AS 
SELECT 
 IDVyrPerZdroje=VPZ.ID, 
 IDPlanKalend=PKP.IDPlanKalend, 
 IDPlanKalendPol=PKP.ID, 
 DatumPripadu=CASE WHEN S.TypSmeny=1 AND PKP.MinDo<=720 THEN PKP.datum-1 
                   WHEN S.TypSmeny=2 AND PKP.MinOd>=720 THEN PKP.datum+1 
                   ELSE PKP.datum END, 
 PKP.datum, PKP.MinOd, PKP.MinDo, PKP.KoefPlneni, PKP.IDSmeny, PKP.CasOd, PKP.CasDo 
   FROM TabVyrPerZdroje VPZ 
     INNER JOIN TabPlanKalendPol PKP ON (PKP.minOd IS NOT NULL AND 
                                         (PKP.IDVyrPerZdroje=VPZ.ID OR 
                                          (PKP.IDPlanKalend=VPZ.IDPlanKalend AND NOT EXISTS(SELECT * FROM TabPlanKalendPol PKP2 WHERE PKP2.IDVyrPerZdroje=VPZ.ID AND PKP2.Datum=PKP.datum)) 
                                         ) ) 
     LEFT OUTER JOIN TabCSmeny S ON (S.ID=PKP.IDSmeny)
GO

