USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_set_archive_popis_neshody]    Script Date: 26.06.2025 10:44:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_set_archive_popis_neshody]
@Archive BIT,
@ID INT
AS

UPDATE RAY_Podtyp_Neshod SET
Archive = @Archive
WHERE ID = @ID
GO

