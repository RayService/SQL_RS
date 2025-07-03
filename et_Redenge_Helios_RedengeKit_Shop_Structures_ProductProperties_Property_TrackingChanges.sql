USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property_TrackingChanges]    Script Date: 03.07.2025 9:40:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property_TrackingChanges] 
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property] 
AFTER INSERT, UPDATE 
AS 
BEGIN 
SET NOCOUNT ON;
	UPDATE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property SET LastChangeDate=GETDATE() 
	WHERE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property.Id IN 
	(SELECT inserted.Id FROM inserted LEFT JOIN deleted ON deleted.Id = inserted.Id WHERE 
		(deleted.LastChangeDate IS NULL OR inserted.LastChangeDate = deleted.LastChangeDate) AND
		(
			(((inserted.Code IS NULL AND deleted.Code IS NOT NULL) OR (inserted.Code IS NOT NULL AND deleted.Code IS NULL)) OR inserted.Code<>deleted.Code) OR
			(((inserted.OrderKoeficient IS NULL AND deleted.OrderKoeficient IS NOT NULL) OR (inserted.OrderKoeficient IS NOT NULL AND deleted.OrderKoeficient IS NULL)) OR inserted.OrderKoeficient<>deleted.OrderKoeficient) OR
			(((inserted.[Type] IS NULL AND deleted.[Type] IS NOT NULL) OR (inserted.[Type] IS NOT NULL AND deleted.[Type] IS NULL)) OR inserted.[Type]<>deleted.[Type]) OR			
			(((inserted.SearchEnable IS NULL AND deleted.SearchEnable IS NOT NULL) OR (inserted.SearchEnable IS NOT NULL AND deleted.SearchEnable IS NULL)) OR inserted.SearchEnable<>deleted.SearchEnable) OR						
			(((inserted.PropertyGroup IS NULL AND deleted.PropertyGroup IS NOT NULL) OR (inserted.PropertyGroup IS NOT NULL AND deleted.PropertyGroup IS NULL)) OR inserted.PropertyGroup<>deleted.PropertyGroup) OR	
			(((inserted.PropertyBox IS NULL AND deleted.PropertyBox IS NOT NULL) OR (inserted.PropertyBox IS NOT NULL AND deleted.PropertyBox IS NULL)) OR inserted.PropertyBox<>deleted.PropertyBox)	
		)
	)
END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property_TrackingChanges]
GO

