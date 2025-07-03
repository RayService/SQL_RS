USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName_TrackingChanges]    Script Date: 03.07.2025 9:47:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName_TrackingChanges] 
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName] 
AFTER INSERT, UPDATE 
AS 
BEGIN 
SET NOCOUNT ON;
	UPDATE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName SET LastChangeDate=GETDATE() 
	WHERE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName.Id IN 
	(SELECT inserted.Id FROM inserted LEFT JOIN deleted ON deleted.Id = inserted.Id WHERE 
		(deleted.LastChangeDate IS NULL OR inserted.LastChangeDate = deleted.LastChangeDate) AND
		(
			(((inserted.Name IS NULL AND deleted.Name IS NOT NULL) OR (inserted.Name IS NOT NULL AND deleted.Name IS NULL)) OR inserted.Name<>deleted.Name) OR
			(((inserted.Culture IS NULL AND deleted.Culture IS NOT NULL) OR (inserted.Culture IS NOT NULL AND deleted.Culture IS NULL)) OR inserted.Culture<>deleted.Culture) OR
			(((inserted.PropertyBoxItem IS NULL AND deleted.PropertyBoxItem IS NOT NULL) OR (inserted.PropertyBoxItem IS NOT NULL AND deleted.PropertyBoxItem IS NULL)) OR inserted.PropertyBoxItem<>deleted.PropertyBoxItem)
		)
	)
END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName_TrackingChanges]
GO

