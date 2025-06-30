USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_automatizace_napocetDOBJ]    Script Date: 30.06.2025 8:13:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_automatizace_napocetDOBJ] @ID INT, @IDKrok INT, @Vyhodnoceni INT, @IDDokladNew INT OUT, @ErrorCode INT OUT, @ErrorMsg NVARCHAR(MAX) OUT

AS

SET @IDDokladNew=0
EXEC dbo.hp_DosleObj_NapocetUdajuZFakturace @ID
GO

