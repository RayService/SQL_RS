USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_ecit]    Script Date: 26.06.2025 11:27:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[hpx_RS_update_ecit]
@ID INT
AS

UPDATE TabKmenZbozi SET CLOPopisZbozi = (SELECT TOP 1 TabClaEcit.ZboziText
FROM TabClaEcit
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.CelniNomenklatura=TabClaEcit.Nomenklatura AND tkz.DopKod=TabClaEcit.DopKod
WHERE tkz.ID = @ID)
WHERE TabKmenZbozi.ID=@ID
GO

