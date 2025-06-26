USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDVycistitRole]    Script Date: 26.06.2025 13:16:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROC [dbo].[hpx_SDVycistitRole]
AS
SET NOCOUNT ON
DELETE FROM Tabx_SDRoleVSchvalovatel
WHERE IdSchvalovatel NOT IN(SELECT ID FROM hvw_SDSchvalovatele)
GO

