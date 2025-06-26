USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_delete_detailni_kalk]    Script Date: 26.06.2025 12:47:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_delete_detailni_kalk] @kontrola BIT, @ID INT
AS
IF @kontrola=1
BEGIN
DELETE FROM TabDetailniKalkulace_kalk WHERE ID=@ID
END
ELSE
RETURN;
GO

