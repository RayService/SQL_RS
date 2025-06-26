USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_set_zkontrolovano_BON]    Script Date: 26.06.2025 10:35:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_set_zkontrolovano_BON]
@_EXT_RS_checked_BON BIT,
@ID INT
AS

UPDATE tdze SET _EXT_RS_checked_BON = @_EXT_RS_checked_BON
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokladyZbozi_EXT tdze ON tdze.ID=tdz.ID
WHERE tdz.ID = @ID
GO

