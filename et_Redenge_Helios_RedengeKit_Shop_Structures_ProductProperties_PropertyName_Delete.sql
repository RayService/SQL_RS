USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName_Delete]    Script Date: 03.07.2025 9:48:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName_Delete]
   ON  [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName]
   AFTER DELETE
AS 
BEGIN
 SET NOCOUNT ON;
 
	INSERT INTO Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedPropertyName
	(PropertyCode, CultureCode )
	SELECT property.Code as PropertyCode, culture.Code as CultureCode FROM 
	deleted
	LEFT JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property property
	ON property.id = deleted.Property
	LEFT JOIN Redenge_Globalization_Culture culture
	ON culture.id = deleted.culture WHERE deleted.LastChangeDate IS NOT NULL AND deleted.LastProcessDate IS NOT NULL
END

GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyName_Delete]
GO

