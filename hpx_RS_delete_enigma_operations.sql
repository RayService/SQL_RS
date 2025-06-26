USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_delete_enigma_operations]    Script Date: 26.06.2025 13:10:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_delete_enigma_operations]
@ID INT
AS

IF (SELECT tpp.ID  FROM TabPrPostup_EXT tpp WHERE tpp.ID=@ID) IS NOT NULL
BEGIN
UPDATE TabPrPostup_EXT SET
_EXT_RS_enigma_date=NULL,
_EXT_RS_enigma_nr=NULL
WHERE ID=@ID
END
GO

