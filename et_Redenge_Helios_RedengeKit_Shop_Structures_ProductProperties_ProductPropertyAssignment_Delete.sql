USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment_Delete]    Script Date: 03.07.2025 9:34:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment_Delete]
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment]
AFTER DELETE 
AS
BEGIN
SET NOCOUNT ON;

INSERT INTO Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedProductPropertyAssignment
(ProductCode, PropertyCode)
SELECT product.SkupZbo +'.'+ product.RegCis as ProductCode, property.Code as PropertyCode
FROM deleted
JOIN TabKmenZbozi product ON product.id = deleted.Zbozi
LEFT JOIN Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_Property property ON property.id = deleted.Property 
WHERE deleted.LastChangeDate IS NOT NULL AND deleted.LastProcessDate IS NOT NULL


END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_ProductPropertyAssignment_Delete]
GO

