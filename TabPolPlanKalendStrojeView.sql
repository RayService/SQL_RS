USE [RayService]
GO

/****** Object:  View [dbo].[TabPolPlanKalendStrojeView]    Script Date: 04.07.2025 11:43:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPolPlanKalendStrojeView] AS 
SELECT 
 IDStroje=CS.ID, 
 IDPlanKalend=PKP.IDPlanKalend, 
 IDPlanKalendPol=PKP.ID, 
 DatumPripadu=CASE WHEN S.TypSmeny=1 AND PKP.MinDo<=720 THEN PKP.datum-1 
                   WHEN S.TypSmeny=2 AND PKP.MinOd>=720 THEN PKP.datum+1 
                   ELSE PKP.datum END, 
 PKP.datum, PKP.MinOd, PKP.MinDo, PKP.KoefPlneni, PKP.IDSmeny, PKP.CasOd, PKP.CasDo 
   FROM TabCisStroju CS 
     INNER JOIN TabPlanKalendPol PKP ON (PKP.minOd IS NOT NULL AND 
                                         (PKP.IDStroje=CS.ID OR 
                                          (PKP.IDPlanKalend=CS.IDPlanKalend AND NOT EXISTS(SELECT * FROM TabPlanKalendPol PKP2 WHERE PKP2.IDStroje=CS.ID AND PKP2.Datum=PKP.datum)) 
                                         ) ) 
     LEFT OUTER JOIN TabCSmeny S ON (S.ID=PKP.IDSmeny)
GO

