USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_zadani_cilove_hodnoty]    Script Date: 26.06.2025 9:56:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_zadani_cilove_hodnoty]
@Target_value_from NUMERIC(19,6),
@Target_value_to NUMERIC(19,6),
@ID INT
AS

UPDATE RAY_Parametry_Values SET
Target_value_from = @Target_value_from,
Target_value_to = @Target_value_to
WHERE ID = @ID
GO

