USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_AutorRealizace]    Script Date: 26.06.2025 8:54:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		OZE
-- Create date: 23.9.2013
-- Description:	Autor realizace výdejky
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RS_AutorRealizace]
@IDDOKLAD INT

AS

IF NOT EXISTS (SELECT * FROM dbo.TabDokladyZbozi_EXT DZE WHERE DZE.ID = @IDDOKLAD)
	BEGIN
		INSERT INTO dbo.TabDokladyZbozi_EXT (ID) VALUES(@IDDOKLAD)
	END

UPDATE TabDokladyZbozi_EXT
SET _RS_AutorRealizace = (SUSER_SNAME())
WHERE ID = @IDDOKLAD
GO

