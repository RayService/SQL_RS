USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property_Delete]    Script Date: 03.07.2025 9:39:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property_Delete]
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property]
AFTER DELETE 
AS
BEGIN
SET NOCOUNT ON;

INSERT INTO Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedProductProperty
(PropertyCode,PropertyGroupCode)
SELECT deleted.Code as Code, propertyGroup.Code as PropertyGroupCode FROM 
deleted 
LEFT JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyGroup propertyGroup
ON propertyGroup.id = deleted.PropertyGroup  WHERE deleted.LastChangeDate IS NOT NULL AND deleted.LastProcessDate IS NOT NULL

END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property_Delete]
GO

