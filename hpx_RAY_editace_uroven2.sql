USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_editace_uroven2]    Script Date: 26.06.2025 11:54:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_editace_uroven2]
@upper_lever2_param nvarchar(MAX),
@ID INT
AS

UPDATE RAY_Parametry_Definice SET
upper_lever2_param = @upper_lever2_param
WHERE ID = @ID
GO

