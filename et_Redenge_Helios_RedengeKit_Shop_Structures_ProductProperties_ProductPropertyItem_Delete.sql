USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem_Delete]    Script Date: 03.07.2025 9:36:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem_Delete]
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem]
AFTER DELETE 
AS
BEGIN
SET NOCOUNT ON;

 IF NOT (SELECT COUNT(Id) FROM Deleted WHERE ProductPropertyAssignment IS NULL) > 0
 BEGIN
	INSERT INTO Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedProductPropertyItem
	(PropertyCode, ProductCode, CultureCode)
	SELECT property.code as propertyCode, product.SkupZbo+'.'+product.RegCis as ProductCode, culture.code as CultureCode
	FROM deleted
	LEFT JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment productPropertyAssignment
	ON productPropertyAssignment.id = deleted.ProductPropertyAssignment
	LEFT JOIN TabKmenZbozi product
	ON productPropertyAssignment.Zbozi = product.id
	LEFT JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property property
	ON productPropertyAssignment.Property = property.id
	LEFT JOIN Redenge_Globalization_Culture culture
	ON culture.id = deleted.culture WHERE deleted.LastChangeDate IS NOT NULL AND deleted.LastProcessDate IS NOT NULL
 END

END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyItem_Delete]
GO

