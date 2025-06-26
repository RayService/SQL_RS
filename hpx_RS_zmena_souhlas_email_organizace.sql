USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_souhlas_email_organizace]    Script Date: 26.06.2025 11:33:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_souhlas_email_organizace] @EmailSouhlas BIT, @kontrola BIT, @ID INT
AS
IF @kontrola = 1
BEGIN
UPDATE TabCisOrg SET EmailSouhlas=@EmailSouhlas WHERE ID = @ID
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

