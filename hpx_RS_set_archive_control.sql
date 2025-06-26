USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_set_archive_control]    Script Date: 26.06.2025 10:48:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_set_archive_control]
@Archive BIT,
@ID INT
AS

UPDATE B2A_Fair_Fair_Inspection_Type SET
Archive = @Archive
WHERE ID = @ID
GO

