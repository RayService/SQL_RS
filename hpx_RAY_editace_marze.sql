USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_editace_marze]    Script Date: 26.06.2025 11:53:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_editace_marze]
@Marze_plan_100 NUMERIC(19,6),
@Marze_plan_200 NUMERIC(19,6),
@ID INT
AS

UPDATE RAY_Marze SET
Marze_plan_100 = @Marze_plan_100,
Marze_plan_200 = @Marze_plan_200
WHERE ID = @ID
GO

