USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem_Delete]    Script Date: 03.07.2025 9:44:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem_Delete]
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem]
AFTER DELETE 
AS
BEGIN
SET NOCOUNT ON;

INSERT INTO Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedPropertyBoxItem
(PropertyBoxCode, PropertyBoxItemCode)
SELECT propertyBox.Code as PropertyBoxCode, deleted.Code as PropertyBoxItemCode
FROM deleted
LEFT JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox propertyBox
ON deleted.PropertyBox = propertyBox.Id WHERE deleted.LastChangeDate IS NOT NULL AND deleted.LastProcessDate IS NOT NULL

END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem_Delete]
GO

