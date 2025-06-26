USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_delete_enigma]    Script Date: 26.06.2025 11:01:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_delete_enigma]
@ID INT
AS

IF (SELECT tp.ID  FROM TabPrikaz_EXT tp WHERE tp.ID=@ID) IS NOT NULL
BEGIN
UPDATE TabPrikaz_EXT SET
_EXT_RS_enigma_date=NULL,
_EXT_RS_enigma_nr=NULL
WHERE ID=@ID
END
GO

