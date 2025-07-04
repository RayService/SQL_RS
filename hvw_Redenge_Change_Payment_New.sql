USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_Payment_New]    Script Date: 04.07.2025 7:50:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_Payment_New] AS 
SELECT u.ID FROM TabFormaUhrady u
LEFT JOIN TabFormaUhrady_EXT e ON e.ID = u.ID
WHERE e._Redenge_LastProcessDate IS NULL 
GO

