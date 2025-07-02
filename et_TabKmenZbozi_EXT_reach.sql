USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKmenZbozi_EXT_reach]    Script Date: 02.07.2025 15:15:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabKmenZbozi_EXT_reach] ON [dbo].[TabKmenZbozi_EXT]
FOR UPDATE
AS
DECLARE @IDPol			INT			-- ID Položky (položek)
SELECT @IDPol = ID FROM inserted
BEGIN
  IF UPDATE(_RAY_Reach)
    if EXISTS(SELECT * FROM TabKmenZbozi_EXT WHERE (ID = @IDPol AND (_RAY_Reach = 0) AND (_EXT_RS_svhc IS NULL))
	) BEGIN
        ROLLBACK
        RAISERROR('Je nutné vyplnit pole SVHC', 16, 1);
	  END
END
GO

ALTER TABLE [dbo].[TabKmenZbozi_EXT] ENABLE TRIGGER [et_TabKmenZbozi_EXT_reach]
GO

