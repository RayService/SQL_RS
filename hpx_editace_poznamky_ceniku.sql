USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_editace_poznamky_ceniku]    Script Date: 26.06.2025 11:50:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_editace_poznamky_ceniku]
@Poznamka NTEXT,
@ID INT
AS
-- =============================================
-- Author:		MŽ
-- Create date:            10.9.2019
-- Description:	Editace poznámky v ceníku
-- =============================================

BEGIN
           UPDATE TabStrukKusovnik_kalk_cenik SET Poznamka =@Poznamka  WHERE ID =@ID
END
GO

