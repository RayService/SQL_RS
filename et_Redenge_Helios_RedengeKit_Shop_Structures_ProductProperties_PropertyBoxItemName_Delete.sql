USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName_Delete]    Script Date: 03.07.2025 9:47:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName_Delete]
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName]
AFTER DELETE 
AS
BEGIN
SET NOCOUNT ON;

 IF NOT (SELECT COUNT(Id) FROM deleted WHERE PropertyBoxItem IS NULL) > 0
 BEGIN
	INSERT INTO Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedPropertyBoxItemName
	(PropertyBoxCode, PropertyBoxItemCode, CultureCode)
	SELECT propertyBox.Code as PropertyBoxCode, propertyBoxItem.Code as PropertyBoxItemCode, 
	culture.Code as CultureCode
	FROM deleted
	LEFT JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItem propertyBoxItem
	ON PropertyBoxItem.id = deleted.PropertyBoxItem
	LEFT JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox propertyBox
	ON propertyBoxItem.PropertyBox = propertyBox.Id
	LEFT JOIN Redenge_Globalization_Culture culture
	ON culture.id = deleted.culture WHERE deleted.LastChangeDate IS NOT NULL AND deleted.LastProcessDate IS NOT NULL
 END

END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBoxItemName_Delete]
GO

