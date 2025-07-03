USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyGroup_TrackingChanges]    Script Date: 03.07.2025 9:48:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyGroup_TrackingChanges] 
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyGroup] 
AFTER INSERT, UPDATE 
AS 
BEGIN 
SET NOCOUNT ON;
	UPDATE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyGroup SET LastChangeDate=GETDATE() 
	WHERE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyGroup.Id IN 
	(SELECT inserted.Id FROM inserted LEFT JOIN deleted ON deleted.Id = inserted.Id WHERE 
		(deleted.LastChangeDate IS NULL OR inserted.LastChangeDate = deleted.LastChangeDate) AND
		(
			(((inserted.Code IS NULL AND deleted.Code IS NOT NULL) OR (inserted.Code IS NOT NULL AND deleted.Code IS NULL)) OR inserted.Code<>deleted.Code) OR
			(((inserted.Name IS NULL AND deleted.Name IS NOT NULL) OR (inserted.Name IS NOT NULL AND deleted.Name IS NULL)) OR inserted.Name<>deleted.Name)
		)
	)
END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyGroup] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyGroup_TrackingChanges]
GO

