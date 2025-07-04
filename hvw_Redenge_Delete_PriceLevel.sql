USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Redenge_Delete_PriceLevel]    Script Date: 04.07.2025 7:35:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Redenge_Delete_PriceLevel] AS 
SELECT ID FROM Redenge_Helios_RedengeKit_Shop_Structures_Prices_DeletedPriceLevel
GO

