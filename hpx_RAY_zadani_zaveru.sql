USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_zadani_zaveru]    Script Date: 26.06.2025 9:56:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_zadani_zaveru]
@Result NTEXT,
@ID INT
AS

UPDATE RAY_Parametry_Values SET
Result = @Result
WHERE ID = @ID
GO

