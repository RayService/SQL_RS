USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HromZmenOZP_SJA]    Script Date: 26.06.2025 12:41:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HromZmenOZP_SJA] @OZP INT, @Prepsat BIT, @ID INT AS

IF @Prepsat=1
BEGIN
 UPDATE TabZamPer
 SET ZPS=@OZP
 WHERE ID=@ID
END
ELSE RAISERROR(N'Nebyly přepsány žádné záznamy', 16, 1)
GO

