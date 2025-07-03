USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox_Delete]    Script Date: 03.07.2025 9:41:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox_Delete]
ON [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox]
AFTER DELETE 
AS
BEGIN
SET NOCOUNT ON;

INSERT INTO Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_DeletedPropertyBox
(Code)
SELECT Code FROM deleted WHERE deleted.LastChangeDate IS NOT NULL AND deleted.LastProcessDate IS NOT NULL

END
GO

ALTER TABLE [dbo].[Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox] ENABLE TRIGGER [et_Redenge_Helios_RedengeKit_Shop_Structures_ProductProperties_PropertyBox_Delete]
GO

