USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem_TrackingChanges]    Script Date: 03.07.2025 9:45:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem_TrackingChanges] 
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem] 
AFTER INSERT, UPDATE 
AS 
BEGIN 
SET NOCOUNT ON;
	UPDATE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem SET LastChangeDate=GETDATE() 
	WHERE Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem.Id IN 
	(SELECT inserted.Id FROM inserted LEFT JOIN deleted ON deleted.Id = inserted.Id WHERE 
		(deleted.LastChangeDate IS NULL OR inserted.LastChangeDate = deleted.LastChangeDate) AND
		(
			(((inserted.Code IS NULL AND deleted.Code IS NOT NULL) OR (inserted.Code IS NOT NULL AND deleted.Code IS NULL)) OR inserted.Code<>deleted.Code) OR
			(((inserted.OrderKoeficient IS NULL AND deleted.OrderKoeficient IS NOT NULL) OR (inserted.OrderKoeficient IS NOT NULL AND deleted.OrderKoeficient IS NULL)) OR inserted.OrderKoeficient<>deleted.OrderKoeficient) OR
			(((inserted.PropertyBox IS NULL AND deleted.PropertyBox IS NOT NULL) OR (inserted.PropertyBox IS NOT NULL AND deleted.PropertyBox IS NULL)) OR inserted.PropertyBox<>deleted.PropertyBox)
		)
	)
END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem_TrackingChanges]
GO

