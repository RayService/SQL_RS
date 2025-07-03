USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory_Deleted]    Script Date: 03.07.2025 9:31:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory_Deleted] 
   ON [dbo].[Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory]  
   AFTER DELETE
AS 
BEGIN
 SET NOCOUNT ON;
 
 INSERT INTO Redenge_Helios_RedengeKit_Shop_DeletedAssignmentShopProductToCategory (ProductId, ProductCode, ShopCategoryId, MultishopId, NavaznaSkupinaZbozi)
 (
  SELECT DISTINCT k.ID, k.SkupZbo + '.' + k.RegCis, deleted.ShopCategoryId, deleted.MultishopId, deleted.NavaznaSkupinaZbozi FROM deleted
  JOIN TabSoz s ON s.id = deleted.NavaznaSkupinaZbozi
  JOIN TabSozNa n ON n.idSoz = s.id
  JOIN TabKmenZbozi k ON k.id = n.IdKmenZbo
  LEFT JOIN TabSozNa s2 ON s2.IDKmenZbo = k.id AND s2.Id <> n.id
  LEFT JOIN Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory c ON c.NavaznaSkupinaZbozi = s2.idSoz AND c.Id <> deleted.Id AND c.ShopCategoryId = deleted.ShopCategoryId
  WHERE c.id IS NULL
 )
END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_AssignmentNavaznaSkupinaToShopCategory_Deleted]
GO

