USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaDatZajKolizeMat]    Script Date: 26.06.2025 13:23:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ZmenaDatZajKolizeMat]
@_EXT_RS_kolize_zajisteni_mat DATETIME,
@kontrola1 bit,
@_EXT_RS_DateEstimated DATETIME,
@kontrola2 bit,
@ID INT
AS
IF @kontrola1 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPlan_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_kolize_zajisteni_mat=@_EXT_RS_kolize_zajisteni_mat WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPlan_EXT (ID,_EXT_RS_kolize_zajisteni_mat)
  VALUES (@ID,@_EXT_RS_kolize_zajisteni_mat);
END
COMMIT TRANSACTION;
END;

IF @kontrola2 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPlan_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_DateEstimated=@_EXT_RS_DateEstimated WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPlan_EXT (ID,_EXT_RS_DateEstimated)
  VALUES (@ID,@_EXT_RS_DateEstimated);
END
COMMIT TRANSACTION;
END;

IF (@kontrola1 = 0 AND @kontrola2 = 0)
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

