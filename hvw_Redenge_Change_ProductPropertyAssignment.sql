USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_ProductPropertyAssignment]    Script Date: 04.07.2025 7:55:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_ProductPropertyAssignment] AS 
SELECT pa.Id FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment pa
JOIN TabKmenZbozi_EXT ke ON ke.ID = pa.Zbozi 
WHERE ke._Redenge_LastProcessDate IS NOT NULL AND ((LastChangeDate > LastProcessDate) OR (LastProcessDate IS NULL))
GO

