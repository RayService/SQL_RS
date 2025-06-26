USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_edit_employee_comlang]    Script Date: 26.06.2025 13:00:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_edit_employee_comlang]
@_EXT_RS_ComLanguage INT,
@kontrola1 BIT,
@ID INT
AS
SET NOCOUNT ON

IF @kontrola1 = 1
UPDATE tcze WITH (UPDLOCK, SERIALIZABLE) SET tcze._EXT_RS_ComLanguage = @_EXT_RS_ComLanguage
	FROM dbo.TabCisZam_EXT tcze
	LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=tcze.ID
	WHERE tcz.ID=@ID;
	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT INTO TabCisZam_EXT(ID, _EXT_RS_ComLanguage)
	  SELECT tcz.ID,@_EXT_RS_ComLanguage
	  FROM dbo.TabCisZam_EXT tcze
	  LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=tcze.ID
	  WHERE tcz.ID=@ID;
	END
IF @kontrola1=0
BEGIN
RAISERROR('Nic neproběhne, není zatržena žádná volba.',16,1)
RETURN;
END;
GO

