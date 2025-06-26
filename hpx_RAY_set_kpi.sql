USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_set_kpi]    Script Date: 26.06.2025 12:35:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_set_kpi]
@KPI BIT,
@ID INT
AS

UPDATE RAY_Parametry_Definice SET
KPI = @KPI
WHERE ID = @ID
GO

