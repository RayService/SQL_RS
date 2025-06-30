USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_DatumProvereniSankcniMapa]    Script Date: 30.06.2025 8:25:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_DatumProvereniSankcniMapa]
@_EXT_RS_ProvereniSankcniMapa DATETIME,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
	UPDATE tcoe
	SET  tcoe._EXT_RS_ProvereniSankcniMapa = @_EXT_RS_ProvereniSankcniMapa
	FROM TabDokladyZbozi tdz
	LEFT OUTER JOIN TabCisOrg tco ON tco.CisloOrg=tdz.CisloOrg
	LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
	WHERE tdz.ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
    INSERT INTO dbo.TabCisOrg_EXT (ID, _EXT_RS_ProvereniSankcniMapa)
    SELECT tco.ID, @_EXT_RS_ProvereniSankcniMapa
    FROM TabDokladyZbozi tdz
    LEFT JOIN TabCisOrg tco ON tco.CisloOrg = tdz.CisloOrg
    WHERE tdz.ID = @ID;
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

