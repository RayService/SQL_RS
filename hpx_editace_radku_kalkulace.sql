USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_editace_radku_kalkulace]    Script Date: 30.06.2025 8:48:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_editace_radku_kalkulace]
@Cena_vypoctena NUMERIC (19,6),
@Poznamka NVARCHAR(MAX),
@ID INT
AS
-- =============================================
-- Author:		MŽ
-- Create date:            3.6.2019
-- Description:	Editace vypočtené ceny v kalkulaci
-- =============================================

BEGIN
	UPDATE TabStrukKusovnik_kalk_cenik SET Cena_vypoctena=@Cena_vypoctena, Poznamka=@Poznamka  WHERE ID =@ID
END;
GO

