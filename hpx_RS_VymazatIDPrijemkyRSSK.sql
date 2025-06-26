USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VymazatIDPrijemkyRSSK]    Script Date: 26.06.2025 16:01:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VymazatIDPrijemkyRSSK] @kontrola BIT, @ID INT
AS

IF @kontrola=1
BEGIN
UPDATE TabDokladyZbozi_EXT SET _EXT_RS_IDPrijemkyRS_SK=NULL WHERE ID=@ID
END
ELSE
BEGIN
RAISERROR('Není zatrženo Provést, nic neproběhne',16,1)
RETURN
END;
GO

