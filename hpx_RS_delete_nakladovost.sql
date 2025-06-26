USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_delete_nakladovost]    Script Date: 26.06.2025 11:38:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_delete_nakladovost] @kontrola BIT, @ID INT
AS
IF @kontrola=1
BEGIN
DELETE FROM Tabx_RS_NakladyZakazky WHERE ID=@ID
END
ELSE
RETURN;
GO

