USE [RayService]
GO

/****** Object:  View [dbo].[TabPolPlanKalendView]    Script Date: 04.07.2025 12:29:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPolPlanKalendView] AS 
SELECT 
 IDPlanKalend=PKP.IDPlanKalend, 
 IDPlanKalendPol=PKP.ID, 
 DatumPripadu=CASE WHEN S.TypSmeny=1 AND PKP.MinDo<=720 THEN PKP.datum-1 
                   WHEN S.TypSmeny=2 AND PKP.MinOd>=720 THEN PKP.datum+1 
                   ELSE PKP.datum END, 
 PKP.datum, PKP.MinOd, PKP.MinDo, PKP.KoefPlneni, PKP.IDSmeny, PKP.CasOd, PKP.CasDo 
   FROM TabPlanKalendPol PKP 
     LEFT OUTER JOIN TabCSmeny S ON (S.ID=PKP.IDSmeny) 
   WHERE PKP.minOd IS NOT NULL AND PKP.IDPlanKalend IS NOT NULL
GO

