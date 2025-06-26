USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_delete_calculation_history]    Script Date: 26.06.2025 12:09:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_delete_calculation_history] @kontrola BIT, @ID INT
AS
IF @kontrola=1
BEGIN
DELETE FROM Tabx_RS_TabKalkulaceHist WHERE ID=@ID
END;
GO

