USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_change_quantity]    Script Date: 26.06.2025 11:11:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_change_quantity]
@kontrola BIT,
@mnozstvi NUMERIC(19,6),
@ID INT
AS

IF @kontrola=1
BEGIN
UPDATE tp SET tp.mnozstvi=@mnozstvi
FROM Tabplan tp
WHERE ID=@ID
END
IF @kontrola=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

