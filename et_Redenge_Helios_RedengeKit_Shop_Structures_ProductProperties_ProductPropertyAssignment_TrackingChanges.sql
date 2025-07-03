USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment_TrackingChanges]    Script Date: 03.07.2025 9:35:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment_TrackingChanges] 
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment] 
AFTER INSERT, UPDATE 
AS 
BEGIN 
SET NOCOUNT ON;
	UPDATE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment SET LastChangeDate=GETDATE() 
	WHERE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment.Id IN 
	(SELECT inserted.Id FROM inserted LEFT JOIN deleted ON deleted.Id = inserted.Id WHERE 
		(deleted.LastChangeDate IS NULL OR inserted.LastChangeDate = deleted.LastChangeDate) AND
		(
			(((inserted.OrderKoeficient IS NULL AND deleted.OrderKoeficient IS NOT NULL) OR (inserted.OrderKoeficient IS NOT NULL AND deleted.OrderKoeficient IS NULL)) OR inserted.OrderKoeficient<>deleted.OrderKoeficient) OR
			(((inserted.Property IS NULL AND deleted.Property IS NOT NULL) OR (inserted.Property IS NOT NULL AND deleted.Property IS NULL)) OR inserted.Property<>deleted.Property)
		)
	)
END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment_TrackingChanges]
GO

