USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_editace_VVK]    Script Date: 26.06.2025 15:19:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*CREATE PROCEDURE dbo.hpx_RayService_editace_VVK
@KJDatOd DATETIME,
@KJDatDo DATETIME,
@ID INT
AS
BEGIN
IF @KJDatOd <> ''
UPDATE TabKmenZbozi SET KJDatOd = @KJDatOd WHERE ID = @ID
END
BEGIN
IF @KJDatDo <> ''
UPDATE TabKmenZbozi SET KJDatDo = @KJDatDo WHERE ID = @ID
END*/
CREATE PROCEDURE [dbo].[hpx_RayService_editace_VVK]
@KJDatOd DATETIME,
@KJDatDo DATETIME,
@DelOd BIT,
@DelDo BIT,
@ID INT
AS
IF @KJDatOd <> ''
BEGIN
UPDATE TabKmenZbozi SET KJDatOd = @KJDatOd WHERE ID = @ID
END
IF @KJDatDo <> ''
BEGIN
UPDATE TabKmenZbozi SET KJDatDo = @KJDatDo WHERE ID = @ID
END
IF @DelOd=1
BEGIN
UPDATE TabKmenZbozi SET KJDatOd = NULL WHERE ID = @ID
END
IF @DelDo=1
BEGIN
UPDATE TabKmenZbozi SET KJDatDo = NULL WHERE ID = @ID
END
GO

