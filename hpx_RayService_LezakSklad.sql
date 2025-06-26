USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_LezakSklad]    Script Date: 26.06.2025 9:54:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_LezakSklad] @ID INT
AS

BEGIN

	IF NOT EXISTS (SELECT 0 FROM dbo.TabStavSkladu_EXT WHERE ID = @ID)
	BEGIN
		INSERT INTO dbo.TabStavSkladu_EXT(ID) VALUES (@ID)
	END

	UPDATE dbo.TabStavSkladu_EXT
	SET _EXT_RayService_lezak_oznaceni_20 = 1
	WHERE ID = @ID
END
GO

