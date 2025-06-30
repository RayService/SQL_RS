USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_TabCisOrg_prirad_dokument]    Script Date: 30.06.2025 9:01:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_TabCisOrg_prirad_dokument]
@IDDoc INT,
@ID INT
AS
IF NOT EXISTS (SELECT * FROM TabDokumVazba WHERE IdentVazby=3 AND IdTab=@ID AND IdDok=@IDDoc)
BEGIN
INSERT INTO TabDokumVazba (IdentVazby,IdTab,IdDok) SELECT 3,ID,@IDDoc FROM TabCisOrg WHERE ID=@ID

IF EXISTS(SELECT _EXT_RS_dokument_QMS FROM TabDokumenty_EXT tde JOIN TabDokumenty td ON td.ID = tde.ID JOIN TabDokumVazba tdv ON tdv.IdDok = td.ID AND tdv.IdTab = @ID)
    BEGIN
        UPDATE TabDokumenty_EXT SET _EXT_RS_dokument_QMS = 1
        FROM TabDokumenty_EXT tde
        JOIN TabDokumenty td ON td.ID = tde.ID
        JOIN TabDokumVazba tdv ON tdv.IdDok = td.ID
        WHERE tdv.IdTab=@ID AND td.ID = @IDDoc
    END
ELSE 
    BEGIN
        INSERT INTO TabDokumenty_EXT (ID,_EXT_RS_dokument_QMS) SELECT ID, 1 FROM TabDokumenty WHERE TabDokumenty.ID=(SELECT td.ID FROM TabDokumenty td JOIN TabDokumVazba tdv ON tdv.IdDok = td.ID WHERE tdv.ID=@ID)
    END
END
GO

