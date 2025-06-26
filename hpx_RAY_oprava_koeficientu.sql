USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RAY_oprava_koeficientu]    Script Date: 26.06.2025 9:57:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RAY_oprava_koeficientu]
@Result_koef_uziv NUMERIC (19,6),
@ID INT
AS

UPDATE RAY_Parametry_Values SET
Result_koef_uziv = @Result_koef_uziv
WHERE ID = @ID
GO

