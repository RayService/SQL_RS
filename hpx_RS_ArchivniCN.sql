USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ArchivniCN]    Script Date: 26.06.2025 15:47:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ArchivniCN]
@kontrola1 BIT,
@Archive BIT,
@ID INT
AS
IF @kontrola1=1
BEGIN
UPDATE Tabx_RS_CNRuskeSankce SET Archive=@Archive, DatArchive=GETDATE(), AuthorArchive=SUSER_SNAME(), BlokovaniEditoru=NULL WHERE ID = @ID
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat',16,1);
RETURN;
END;
GO

