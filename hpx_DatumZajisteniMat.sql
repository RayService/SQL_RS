USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_DatumZajisteniMat]    Script Date: 26.06.2025 9:41:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[hpx_DatumZajisteniMat] @DatZajisteni DATETIME, @PoznKMat NVARCHAR(250), @ID INT
AS

IF NOT EXISTS(SELECT * FROM TabPrKVazby_EXT WHERE Id=@ID)
  INSERT INTO TabPrKVazby_EXT(ID) VALUES(@ID)

update TabPrKVazby_EXT

set _DatZajMat=(CASE WHEN @DatZajisteni IS NULL THEN _DatZajMat ELSE @DatZajisteni END),

_PoznamkaKMat=(CASE WHEN @PoznKMat='' THEN _PoznamkaKMat ELSE @PoznKMat END)


where TabPrKVazby_EXT.id=@id
GO

