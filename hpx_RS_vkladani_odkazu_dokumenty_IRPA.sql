USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_vkladani_odkazu_dokumenty_IRPA]    Script Date: 26.06.2025 10:36:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_vkladani_odkazu_dokumenty_IRPA]
	@IDDoklad INT		-- ID Dokladu v TabDokladyZbozi
AS
SET NOCOUNT ON
DECLARE @IDfile INT;
DECLARE @Text3 NVARCHAR(4000);
SET @Text3 = CONVERT(NVARCHAR(MAX),(SELECT tdze._EXT_RS_path_attachements FROM TabDokladyZbozi_EXT tdze LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tdze.ID WHERE tdz.ID=@IDDoklad))
IF(OBJECT_ID('tempdb..#Tabx_files') IS NOT NULL) BEGIN DROP TABLE #Tabx_files END
CREATE TABLE #Tabx_files (ID INT IDENTITY (1,1), File_path NVARCHAR(255))
INSERT INTO #Tabx_files(File_path)
SELECT * FROM STRING_SPLIT (@Text3,';')
BEGIN
DECLARE Cur1 CURSOR FOR
    SELECT ID From #Tabx_files WHERE File_path <> '';
OPEN Cur1
FETCH NEXT FROM Cur1 INTO @IDfile;
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO TabDokumenty (Popis, JmenoACesta, VseobDok, SledovatHistorii)
SELECT RIGHT(File_path, CHARINDEX('\', REVERSE(File_path)) - 1),File_path,1,0
FROM #Tabx_files WHERE ID=@IDFile AND File_path<>''
SELECT SCOPE_IDENTITY()
INSERT INTO TabDokumVazba (IdentVazby,IdTab,IdDok) 
SELECT 9,ID,SCOPE_IDENTITY() FROM TabDokladyZbozi WHERE ID=@IDDoklad
FETCH NEXT FROM Cur1 INTO @IDfile;
END;
CLOSE Cur1;
DEALLOCATE Cur1;
END;
GO

