USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromadnaZmenaUdajuInvHead]    Script Date: 26.06.2025 14:02:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_HromadnaZmenaUdajuInvHead]
@ZamSprac INT,
@Prepsat1 BIT,
@ZamSchvalil INT,
@Prepsat2 BIT,
@DatumClose DATETIME,
@Prepsat3 BIT,
@DatumGenerovani DATETIME,
@Prepsat4 BIT,
@ID INT
AS
DECLARE @Stav TINYINT

BEGIN
	SELECT @Stav=Stav FROM TabInvHead WHERE ID=@ID
	
	BEGIN
	IF @Stav=0 AND @Prepsat1=1
	UPDATE ih SET ZamSprac=@ZamSprac
	FROM TabInvHead ih
	WHERE ih.ID=@ID
	IF @Stav=0 AND @Prepsat2=1
	UPDATE ih SET ZamSchvalil=@ZamSchvalil
	FROM TabInvHead ih
	WHERE ih.ID=@ID
	IF @Stav=0 AND @Prepsat3=1
	UPDATE ih SET DatumClose=@DatumClose
	FROM TabInvHead ih
	WHERE ih.ID=@ID
	IF @Stav=0 AND @Prepsat4=1
	UPDATE ih SET DatumGenerovani=@DatumGenerovani
	FROM TabInvHead ih
	WHERE ih.ID=@ID
		
	IF @Prepsat1=0 AND @Prepsat2=0 AND @Prepsat3=0 AND @Prepsat4=0
	BEGIN
		RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
		RETURN
	END;
	END;
END;
GO

