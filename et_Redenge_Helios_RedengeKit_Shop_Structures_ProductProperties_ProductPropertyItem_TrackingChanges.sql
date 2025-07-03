USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem_TrackingChanges]    Script Date: 03.07.2025 9:37:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem_TrackingChanges] 
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem] 
AFTER INSERT, UPDATE 
AS 
BEGIN 
SET NOCOUNT ON;
	UPDATE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem SET LastChangeDate=GETDATE() 
	WHERE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem.Id IN 
	(SELECT inserted.Id FROM inserted LEFT JOIN deleted ON deleted.Id = inserted.Id WHERE 
		(deleted.LastChangeDate IS NULL OR inserted.LastChangeDate = deleted.LastChangeDate) AND
		(
			(((inserted.[Text] IS NULL AND deleted.[Text] IS NOT NULL) OR (inserted.[Text] IS NOT NULL AND deleted.[Text] IS NULL)) OR inserted.[Text]<>deleted.[Text]) OR
			(((inserted.Number IS NULL AND deleted.Number IS NOT NULL) OR (inserted.Number IS NOT NULL AND deleted.Number IS NULL)) OR inserted.Number<>deleted.Number) OR
			(((inserted.ProductPropertyAssignment IS NULL AND deleted.ProductPropertyAssignment IS NOT NULL) OR (inserted.ProductPropertyAssignment IS NOT NULL AND deleted.ProductPropertyAssignment IS NULL)) OR inserted.ProductPropertyAssignment<>deleted.ProductPropertyAssignment) OR
			(((inserted.PropertyBoxItem IS NULL AND deleted.PropertyBoxItem IS NOT NULL) OR (inserted.PropertyBoxItem IS NOT NULL AND deleted.PropertyBoxItem IS NULL)) OR inserted.PropertyBoxItem<>deleted.PropertyBoxItem)
		)
	)
END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem_TrackingChanges]
GO

