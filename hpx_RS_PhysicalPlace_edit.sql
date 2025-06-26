USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PhysicalPlace_edit]    Script Date: 26.06.2025 11:58:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_PhysicalPlace_edit]
@IDPhysicalPlace INT,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabUmisteni_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_PhysicalPlace=@IDPhysicalPlace WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabUmisteni_EXT (ID,_EXT_RS_PhysicalPlace)
  VALUES (@ID,@IDPhysicalPlace);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;


GO

