USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_Property]    Script Date: 04.07.2025 7:57:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_Property] AS 
SELECT Id FROM Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property
WHERE (LastChangeDate > LastProcessDate) OR (LastProcessDate IS NULL)
GO

