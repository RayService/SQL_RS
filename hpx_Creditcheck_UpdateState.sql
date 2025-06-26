USE [RayService]
GO

DECLARE @RC int
DECLARE @SystemDB nvarchar(40)
DECLARE @IDOrgInput int
DECLARE @Zeme nvarchar(3)

-- TODO: Tady nastavte hodnoty parametrů.

EXECUTE @RC = [dbo].[hpx_Creditcheck_UpdateState] 
   @SystemDB
  ,@IDOrgInput
  ,@Zeme
GO

