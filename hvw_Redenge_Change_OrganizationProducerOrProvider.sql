USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_OrganizationProducerOrProvider]    Script Date: 04.07.2025 7:49:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_OrganizationProducerOrProvider] AS 
SELECT o.id FROM TabCisOrg o
JOIN TabCisOrg_EXT e ON o.ID = e.ID
WHERE _Redenge_ProducerOrProvider = 1 AND _Redenge_LastChangeDate > _Redenge_LastProcessDate
GO

