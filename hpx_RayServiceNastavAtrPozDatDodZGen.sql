USE [RayService]
GO

DECLARE @RC int
DECLARE @datum datetime
DECLARE @pohybId int

-- TODO: Tady nastavte hodnoty parametrů.

EXECUTE @RC = [dbo].[hpx_RayServiceNastavAtrPozDatDodZGen] 
   @datum
  ,@pohybId
GO

