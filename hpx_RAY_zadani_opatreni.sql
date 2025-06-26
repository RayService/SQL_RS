USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_zadani_opatreni]    Script Date: 26.06.2025 9:57:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_zadani_opatreni]
@Opatreni NTEXT,
@ID INT
AS

UPDATE RAY_Parametry_Values SET
Opatreni = @Opatreni
WHERE ID = @ID
GO

