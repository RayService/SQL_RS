USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_delete_distribucni_seznam_QMS]    Script Date: 26.06.2025 11:55:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_delete_distribucni_seznam_QMS]
@IDZam INT,
@ID INT
AS

BEGIN

IF @IDZam IN (SELECT IDZam FROM TabKJUcastZam WHERE IDKJ=@ID)

BEGIN
DELETE TabKJUcastZam WHERE (TabKJUcastZam.IDKJ=@ID AND TabKJUcastZam.IDZam=@IDZam)
END

END
GO

