USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_delete]    Script Date: 26.06.2025 11:39:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_delete] @Souhlas BIT, @ID INT
AS
IF @Souhlas=1
BEGIN
DELETE FROM Tabx_RS_ZKalkulace WHERE ID=@ID
END
ELSE
RETURN
GO

