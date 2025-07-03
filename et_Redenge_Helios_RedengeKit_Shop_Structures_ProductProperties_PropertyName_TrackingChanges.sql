USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName_TrackingChanges]    Script Date: 03.07.2025 9:49:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName_TrackingChanges]
   ON  [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName]
   AFTER UPDATE, INSERT
AS 
BEGIN
 SET NOCOUNT ON;

	UPDATE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName SET LastChangeDate=GETDATE() 
	WHERE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName.Id IN 
	(SELECT inserted.Id FROM inserted LEFT JOIN deleted ON deleted.Id = inserted.Id WHERE 
		(deleted.LastChangeDate IS NULL OR inserted.LastChangeDate = deleted.LastChangeDate) AND
		(
			(((inserted.Name IS NULL AND deleted.Name IS NOT NULL) OR (inserted.Name IS NOT NULL AND deleted.Name IS NULL)) OR inserted.Name<>deleted.Name) OR
			(((inserted.[Description] IS NULL AND deleted.[Description] IS NOT NULL) OR (inserted.[Description] IS NOT NULL AND deleted.[Description] IS NULL)) OR inserted.[Description]<>deleted.[Description]) OR			
			(((inserted.Property IS NULL AND deleted.Property IS NOT NULL) OR (inserted.Property IS NOT NULL AND deleted.Property IS NULL)) OR inserted.Property<>deleted.Property) OR						
			(((inserted.Culture IS NULL AND deleted.Culture IS NOT NULL) OR (inserted.Culture IS NOT NULL AND deleted.Culture IS NULL)) OR inserted.Culture<>deleted.Culture) OR	
			(((inserted.Unit IS NULL AND deleted.Unit IS NOT NULL) OR (inserted.Unit IS NOT NULL AND deleted.Unit IS NULL)) OR inserted.Unit<>deleted.Unit)	
		)
	)		
END

GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName_TrackingChanges]
GO

