USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKmenZbozi_EXT_dodaci_lhuta]    Script Date: 02.07.2025 15:14:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabKmenZbozi_EXT_dodaci_lhuta] ON [dbo].[TabKmenZbozi_EXT]
FOR UPDATE
AS
DECLARE @IDPol			INT			-- ID Položky (položek)
SELECT @IDPol = ID FROM inserted
BEGIN
  IF UPDATE(_EXT_RS_dodaci_lhuta_tydny)
    BEGIN
    UPDATE TabKmenZbozi
	SET DodaciLhuta = (SELECT (K._EXT_RS_dodaci_lhuta_tydny * 7)
								FROM TabKmenZbozi_EXT K
								WHERE K.ID = @IDPol)
	WHERE TabKmenZbozi.ID = @IDPol
	END
END
GO

ALTER TABLE [dbo].[TabKmenZbozi_EXT] ENABLE TRIGGER [et_TabKmenZbozi_EXT_dodaci_lhuta]
GO

