USE [RayService]
GO

DECLARE @RC int
DECLARE @dokladId int

-- TODO: Tady nastavte hodnoty parametrů.

EXECUTE @RC = [dbo].[hpx_RayServiceDotiahniDoporucenuMarzu] 
   @dokladId
GO

