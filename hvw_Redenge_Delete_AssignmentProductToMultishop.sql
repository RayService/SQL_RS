USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_AssignmentProductToMultishop]    Script Date: 04.07.2025 7:28:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_AssignmentProductToMultishop] AS 
SELECT kmenZbozi.SkupZbo +'.'+kmenZbozi.RegCis as Code, assignment.MultishopId as MultishopID FROM TabKmenZbozi kmenZbozi
JOIN TabSozNa n ON n.IDKmenZbo = kmenZbozi.ID
JOIN Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory assignment ON assignment.NavaznaSkupinaZbozi = n.IDSoz
GO

