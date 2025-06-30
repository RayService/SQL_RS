USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VazbaPolRamcKoOb]    Script Date: 30.06.2025 8:10:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VazbaPolRamcKoOb] @_EXT_RS_IDPolRamcKoOb INT, @ID INT
AS
SET NOCOUNT ON;

--cvičně:
--DECLARE @_EXT_RS_IDPolRamcKoOb INT=25
--DECLARE @ID INT=12564

--ostře
DECLARE @KusyKoop NUMERIC(19,6)
SET @KusyKoop=(SELECT Kusy FROM TabPolKoopObj WHERE ID=@ID)

--připojím položku rámcovky k položce koob
IF (SELECT polkoe.ID  FROM TabPolKoopObj_EXT polkoe WHERE polkoe.ID=@ID) IS NULL
BEGIN 
    INSERT INTO TabPolKoopObj_EXT (ID,_EXT_RS_IDPolRamcKoOb)
    VALUES (@ID,@_EXT_RS_IDPolRamcKoOb)
END;
ELSE
BEGIN
	UPDATE polkoe SET _EXT_RS_IDPolRamcKoOb=@_EXT_RS_IDPolRamcKoOb
	FROM TabPolKoopObj polko
	LEFT OUTER JOIN TabPolKoopObj_EXT polkoe ON polkoe.ID=polko.ID
	WHERE
	(polko.ID=@ID)
END;

--odečtu množství položky koop.objednávky od kusů rámcové objednávky a uložím 
BEGIN
UPDATE rpol SET KusyPrevedene=KusyPrevedene+@KusyKoop
FROM Tabx_RS_PolRamcKoopObj rpol
WHERE rpol.ID=@_EXT_RS_IDPolRamcKoOb
END;




GO

