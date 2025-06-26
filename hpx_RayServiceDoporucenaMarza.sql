USE [RayService]
GO

DECLARE @RC int
DECLARE @typAkcie tinyint
DECLARE @skupZbo nvarchar(3)
DECLARE @cisloOrg int
DECLARE @marza numeric(19,6)
DECLARE @oznacenyZaznam int

-- TODO: Tady nastavte hodnoty parametrů.

EXECUTE @RC = [dbo].[hpx_RayServiceDoporucenaMarza] 
   @typAkcie
  ,@skupZbo
  ,@cisloOrg
  ,@marza
  ,@oznacenyZaznam
GO

