USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_SmazRadekLog]    Script Date: 26.06.2025 8:49:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Create date: 12.5.2012
-- Description:	Synchronizace - Smazání řádku z logu
-- =============================================
CREATE PROCEDURE [dbo].[hpx_Synchro_SmazRadekLog]
	@ID INT			-- ID v Tabx_SynchroLog
AS
SET NOCOUNT ON;
DELETE FROM Tabx_SynchroLog WHERE ID = @ID;
GO

