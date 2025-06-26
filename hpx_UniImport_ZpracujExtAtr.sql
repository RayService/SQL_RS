USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImport_ZpracujExtAtr]    Script Date: 26.06.2025 10:14:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImport_ZpracujExtAtr]
@ImportIdent INT,
@IdImpTable INT,
@IdTargetTable INT,
@Chyba NVARCHAR(4000) OUT,
@Polozky BIT = 0,
@TxtPolozkyOZ BIT = 0
AS
DECLARE @ExtAtrSysName NVARCHAR(128), @ExtAtrValue NVARCHAR(MAX), @ExtTableSysName NVARCHAR(128), @ExtTableSysName2 NVARCHAR(128), @ExtTableSysName3 NVARCHAR(128), @SQLString NVARCHAR(MAX)
SET @ExtTableSysName = ''
SET @Chyba = ''
IF @ImportIdent = 0
SET @ExtTableSysName = 'TabCisOrg_EXT'
IF @ImportIdent = 1
SET @ExtTableSysName = 'TabCisZam_EXT'
IF @ImportIdent = 2
SET @ExtTableSysName = 'TabZakazka_EXT'
IF @ImportIdent = 4
SET @ExtTableSysName = 'TabKmenZbozi_EXT'
IF @ImportIdent = 5
BEGIN
IF (SELECT DruhPohybuZbo FROM TabUniImportOZ WHERE ID=@IdImpTable) = 53
BEGIN
  IF (SELECT ISNULL(TypDOBJ, 0) FROM TabUniImportOZ WHERE ID=@IdImpTable)=0
  BEGIN
    SET @ExtTableSysName  = 'TabDosleObjH01_EXT'
    SET @ExtTableSysName2 = 'TabDosleObjR01_EXT'
  END
  ELSE
  BEGIN
    SET @ExtTableSysName  = 'TabDosleObjH02_EXT'
    SET @ExtTableSysName2 = 'TabDosleObjR02_EXT'
  END
END
ELSE
BEGIN
  SET @ExtTableSysName  = 'TabDokladyZbozi_EXT'
  SET @ExtTableSysName2 = 'TabPohybyZbozi_EXT'
  SET @ExtTableSysName3 = 'TabOZTxtPol_EXT'
END
END
IF @ImportIdent = 6
SET @ExtTableSysName = 'TabSortiment_EXT'
IF @ImportIdent = 10
SET @ExtTableSysName = 'TabMaPrZa_EXT'
IF @ImportIdent = 11
SET @ExtTableSysName = 'TabDenikImp'
IF @ExtTableSysName = ''
RETURN
DECLARE @TAB_MainTablesSysName TABLE(TableName NVARCHAR(128))
DECLARE @Delka INT
IF @ExtTableSysName<>''
BEGIN
SET @Delka=LEN(@ExtTableSysName)
IF @ImportIdent=11
INSERT @TAB_MainTablesSysName(TableName) VALUES(N'TabDenik')
ELSE
INSERT @TAB_MainTablesSysName(TableName) VALUES(LEFT(@ExtTableSysName, @Delka - 4))
END
IF @ExtTableSysName2<>''
BEGIN
SET @Delka=LEN(@ExtTableSysName2)
IF @ImportIdent=11
INSERT @TAB_MainTablesSysName(TableName) VALUES(N'TabDenik')
ELSE
INSERT @TAB_MainTablesSysName(TableName) VALUES(LEFT(@ExtTableSysName2, @Delka - 4))
END
IF @ExtTableSysName3<>''
BEGIN
SET @Delka=LEN(@ExtTableSysName3)
IF @ImportIdent=11
INSERT @TAB_MainTablesSysName(TableName) VALUES(N'TabDenik')
ELSE
INSERT @TAB_MainTablesSysName(TableName) VALUES(LEFT(@ExtTableSysName3, @Delka - 4))
END
DECLARE @MainTableName NVARCHAR(128)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT TableName FROM @TAB_MainTablesSysName
OPEN c
WHILE 1=1
BEGIN
FETCH NEXT FROM c INTO @MainTableName
IF @@fetch_status<>0 BREAK
UPDATE TabUniImportExtAtr SET
ExtAtrValue=REPLACE(ExtAtrValue, N',', N'.')
WHERE ImportIdent=@ImportIdent
AND AtrSysName IN(SELECT NazevAtrSys
FROM TabUzivAtr
WHERE Externi=1
AND NazevTabulkySys=@MainTableName
AND TypAtr='NUMERIC')
END
DEALLOCATE c
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT AtrSysName, ExtAtrValue FROM dbo.TabUniImportExtAtr
WHERE ImportIdent = @ImportIdent
AND IdImpTable = @IdImpTable
OPEN c
WHILE 1=1
BEGIN
FETCH NEXT FROM c INTO @ExtAtrSysName, @ExtAtrValue
IF @@fetch_status<>0 BREAK
IF @ExtAtrValue IS NOT NULL
IF @ImportIdent<>11
BEGIN
IF @Polozky=1
BEGIN
IF @TxtPolozkyOZ=0
IF (OBJECT_ID(@ExtTableSysName2, 'U') IS NOT NULL) AND (COLUMNPROPERTY(OBJECT_ID(@ExtTableSysName2, 'U'), @ExtAtrSysName, 'AllowsNull') IS NOT NULL)
BEGIN
SET @SQLString =              N'IF EXISTS(SELECT ID FROM ' + @ExtTableSysName2 + N' WHERE ID=' + CAST(@IdTargetTable AS NVARCHAR(10)) + N')'
SET @SQLString = @SQLString + N'  UPDATE ' + @ExtTableSysName2 + N' SET ' + @ExtAtrSysName + N'= N''' + @ExtAtrValue + N''' WHERE ID=' + CAST(@IdTargetTable AS NVARCHAR(10))
SET @SQLString = @SQLString + N' ELSE'
SET @SQLString = @SQLString + N'  INSERT ' + @ExtTableSysName2 + N'(ID, ' + @ExtAtrSysName + N') VALUES(' + CAST(@IdTargetTable AS NVARCHAR(10)) + ', N''' + @ExtAtrValue + ''')'
EXECUTE sp_executesql @SQLString
END
IF @TxtPolozkyOZ=1
IF (OBJECT_ID(@ExtTableSysName3, 'U') IS NOT NULL) AND (COLUMNPROPERTY(OBJECT_ID(@ExtTableSysName3, 'U'), @ExtAtrSysName, 'AllowsNull') IS NOT NULL)
BEGIN
SET @SQLString =              N'IF EXISTS(SELECT ID FROM ' + @ExtTableSysName3 + N' WHERE ID=' + CAST(@IdTargetTable AS NVARCHAR(10)) + N')'
SET @SQLString = @SQLString + N'  UPDATE ' + @ExtTableSysName3 + N' SET ' + @ExtAtrSysName + N'= N''' + @ExtAtrValue + N''' WHERE ID=' + CAST(@IdTargetTable AS NVARCHAR(10))
SET @SQLString = @SQLString + N' ELSE'
SET @SQLString = @SQLString + N'  INSERT ' + @ExtTableSysName3 + N'(ID, ' + @ExtAtrSysName + N') VALUES(' + CAST(@IdTargetTable AS NVARCHAR(10)) + ', N''' + @ExtAtrValue + ''')'
EXECUTE sp_executesql @SQLString
END
END
ELSE
BEGIN
IF (OBJECT_ID(@ExtTableSysName, 'U') IS NOT NULL) AND (COLUMNPROPERTY(OBJECT_ID(@ExtTableSysName, 'U'), @ExtAtrSysName, 'AllowsNull') IS NOT NULL)
BEGIN
SET @SQLString =              N'IF EXISTS(SELECT ID FROM ' + @ExtTableSysName + N' WHERE ID=' + CAST(@IdTargetTable AS NVARCHAR(10)) + N')'
SET @SQLString = @SQLString + N'  UPDATE ' + @ExtTableSysName + N' SET ' + @ExtAtrSysName + N'= N''' + @ExtAtrValue + N''' WHERE ID=' + CAST(@IdTargetTable AS NVARCHAR(10))
SET @SQLString = @SQLString + N' ELSE'
SET @SQLString = @SQLString + N'  INSERT ' + @ExtTableSysName + N'(ID, ' + @ExtAtrSysName + N') VALUES(' + CAST(@IdTargetTable AS NVARCHAR(10)) + ', N''' + @ExtAtrValue + ''')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
IF ((OBJECT_ID(@ExtTableSysName2, 'U') IS NULL) OR (COLUMNPROPERTY(OBJECT_ID(@ExtTableSysName2, 'U'), @ExtAtrSysName, 'AllowsNull') IS NULL))
AND((OBJECT_ID(@ExtTableSysName3, 'U') IS NULL) OR (COLUMNPROPERTY(OBJECT_ID(@ExtTableSysName3, 'U'), @ExtAtrSysName, 'AllowsNull') IS NULL))
BEGIN
IF @Chyba <>'' SET @Chyba = @Chyba + ', '
SET @Chyba = @Chyba + @ExtAtrSysName
END
END
END
END
ELSE
BEGIN
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtrSysName,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtrSysName + ' NVARCHAR(255) NULL'
EXEC sp_executesql @SQLString
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtrSysName+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtrSysName, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtrSysName
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtrSysName,'COLUMN ' + @ExtAtrSysName)
SET @SQLString=N'UPDATE TabDenikImp SET ' + @ExtAtrSysName + N'=N' + '''' + @ExtAtrValue + '''' + N' WHERE ID=' + CAST(@IdTargetTable AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
END
DEALLOCATE c
GO

