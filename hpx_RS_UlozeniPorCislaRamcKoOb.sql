USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UlozeniPorCislaRamcKoOb]    Script Date: 30.06.2025 8:09:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_UlozeniPorCislaRamcKoOb] @ID INT
AS

DECLARE @IDSession NVARCHAR(32)
SET @IDSession=(SELECT @@SPID)
DELETE FROM Tabx_RS_IDRamcKoOB WHERE IDSession=@IDSession
INSERT INTO Tabx_RS_IDRamcKoOB (Autor, IDSession, IDHlavicka)
VALUES (SUSER_SNAME(), @IDSession, @ID)



GO

