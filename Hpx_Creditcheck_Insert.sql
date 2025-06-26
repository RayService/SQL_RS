USE [RayService]
GO

DECLARE @RC int
DECLARE @ICO nvarchar(20)
DECLARE @Stav tinyint

-- TODO: Tady nastavte hodnoty parametrů.

EXECUTE @RC = [dbo].[hpx_Creditcheck_Insert] 
   @ICO
  ,@Stav
GO

