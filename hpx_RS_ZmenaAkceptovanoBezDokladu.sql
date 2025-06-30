USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaAkceptovanoBezDokladu]    Script Date: 30.06.2025 8:10:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaAkceptovanoBezDokladu]
@_EXT_RS_AkceptaceBezDokladu BIT,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabCisOrg_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_AkceptaceBezDokladu=@_EXT_RS_AkceptaceBezDokladu WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabCisOrg_EXT (ID,_EXT_RS_AkceptaceBezDokladu)
  VALUES (@ID,@_EXT_RS_AkceptaceBezDokladu);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

