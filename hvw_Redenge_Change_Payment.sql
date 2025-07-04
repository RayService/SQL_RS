USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Change_Payment]    Script Date: 04.07.2025 7:49:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Change_Payment] AS 
SELECT u.ID FROM TabFormaUhrady u
JOIN TabFormaUhrady_EXT e ON e.ID = u.ID
WHERE e._Redenge_LastChangeDate > e._Redenge_LastProcessDate
GO

