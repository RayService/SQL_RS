USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_backOffice]    Script Date: 26.06.2025 14:13:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_backOffice] @OsobazaBO NVARCHAR(20), @ID INT
AS

IF NOT EXISTS (SELECT * FROM TabCisOrg_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabCisOrg_EXT (ID)
             VALUES (@ID)
    End

UPDATE TabCisOrg_EXT
SET _backOffice =@OsobazaBO
WHERE ID =@ID
GO

