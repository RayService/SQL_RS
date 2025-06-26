USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ChangeSupplierOUT_PURCH]    Script Date: 26.06.2025 16:01:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ChangeSupplierOUT_PURCH] @Kontrola BIT, @Supplier INT, @ID INT
AS

IF @Kontrola=1
BEGIN
UPDATE GTabAPSLogis_OUT_PURCHASEORDERPROPOSAL SET SUPPLIER_ID=@Supplier WHERE ID=@ID
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Provést.',16,1)
RETURN
END;
GO

