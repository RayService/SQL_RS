USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_evidencni_stredisko]    Script Date: 26.06.2025 11:52:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_evidencni_stredisko] @_EXT_RS_evidencni_stredisko NVARCHAR(30), @ID INT
AS
IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabKmenZbozi_EXT (ID)
             VALUES (@ID)
    End

UPDATE TabKmenZbozi_EXT
SET _EXT_RS_evidencni_stredisko =@_EXT_RS_evidencni_stredisko
WHERE ID =@ID
GO

