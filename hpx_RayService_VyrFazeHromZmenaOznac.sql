USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_VyrFazeHromZmenaOznac]    Script Date: 26.06.2025 9:03:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RayService_VyrFazeHromZmenaOznac]
	@IDTypPostup INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Hromadna editace vyrobnich fazi - oznaceni
-- =============================================

IF EXISTS(SELECT * FROM Tabx_ReseniHeO_SpidOzn
		WHERE TabName = N'TabTypPostup'
			AND SPID = @@SPID
			AND IDTab = @IDTypPostup)
	DELETE FROM Tabx_ReseniHeO_SpidOzn
		WHERE TabName = N'TabTypPostup'
			AND SPID = @@SPID
			AND IDTab = @IDTypPostup;
ELSE
	INSERT INTO Tabx_ReseniHeO_SpidOzn(
		Tabname
		,SPID
		,IDTab)
	VALUES(
		 N'TabTypPostup'
		,@@SPID
		,@IDTypPostup);
GO

