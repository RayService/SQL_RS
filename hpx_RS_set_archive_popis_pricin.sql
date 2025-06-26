USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_set_archive_popis_pricin]    Script Date: 26.06.2025 10:43:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_set_archive_popis_pricin]
@Archive BIT,
@ID INT
AS

UPDATE RAY_PricinaEx SET
Archive = @Archive
WHERE ID = @ID
GO

