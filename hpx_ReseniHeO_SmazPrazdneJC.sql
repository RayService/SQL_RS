USE [RayService]
GO

DECLARE @RC int
DECLARE @IDStavSkladu int

-- TODO: Tady nastavte hodnoty parametrů.

EXECUTE @RC = [dbo].[hpx_ReseniHeO_SmazPrazdneJC] 
   @IDStavSkladu
GO

