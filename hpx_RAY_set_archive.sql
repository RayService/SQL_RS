USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_set_archive]    Script Date: 26.06.2025 10:34:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_set_archive]
@Archive BIT,
@ID INT
AS

UPDATE RAY_Parametry_Definice SET
Archive = @Archive
WHERE ID = @ID
GO

