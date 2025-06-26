USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_set_evidovat_pouze_1x]    Script Date: 26.06.2025 11:02:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_set_evidovat_pouze_1x]
@evidovat BIT,
@ID INT
AS

UPDATE prpe SET _EXT_RS_evidence_jedenkrat = @evidovat
FROM TabPrPostup prp
LEFT OUTER JOIN TabPrPostup_EXT prpe ON prpe.ID=prp.ID
WHERE prp.ID = @ID
GO

