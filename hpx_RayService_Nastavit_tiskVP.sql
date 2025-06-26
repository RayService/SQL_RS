USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_Nastavit_tiskVP]    Script Date: 26.06.2025 9:33:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_Nastavit_tiskVP]
  @tiskVP BIT,
  @ID INT
AS
SET NOCOUNT ON

IF NOT EXISTS(SELECT 0 FROM TabVyrDokum_EXT WHERE ID=@ID)
 INSERT INTO TabVyrDokum_EXT (ID) VALUES (@ID)

UPDATE TabVyrDokum_EXT SET _tiskVP=@tiskVP WHERE ID=@ID
GO

