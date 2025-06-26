USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HromZmenKodUzemi_SJA]    Script Date: 26.06.2025 12:41:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HromZmenKodUzemi_SJA] @ZUJ NVARCHAR(20), @Prepsat BIT, @ID INT AS

IF @Prepsat=1
BEGIN
 UPDATE TabZamPer
 SET KodUzemi=@ZUJ
 WHERE ID=@ID
END
ELSE RAISERROR(N'Nebyly přepsány žádné záznamy', 16, 1)
GO

