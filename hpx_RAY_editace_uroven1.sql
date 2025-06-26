USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_editace_uroven1]    Script Date: 26.06.2025 11:55:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_editace_uroven1]
@upper_lever1_param nvarchar(MAX),
@ID INT
AS

UPDATE RAY_Parametry_Definice SET
upper_lever1_param = @upper_lever1_param
WHERE ID = @ID
GO

