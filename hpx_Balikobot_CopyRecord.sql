USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_CopyRecord]    Script Date: 26.06.2025 14:28:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_CopyRecord]
@TabName NVARCHAR(128),
@WhereSysSourceTab NVARCHAR(MAX),
@IgnoreAtrList NVARCHAR(MAX)=N'',
@ReplaceAtr1 NVARCHAR(128)=N'',
@ReplaceValue1 NVARCHAR(MAX)=N'',
@ReplaceAtr2 NVARCHAR(128)=N'',
@ReplaceValue2 NVARCHAR(MAX)=N'',
@IDTargetRecord INT=NULL OUTPUT
AS
SET NOCOUNT ON
DECLARE @Skript NVARCHAR(MAX),
@SeznamAtributu NVARCHAR(MAX)=N'',
@ParmDefinition NVARCHAR(100)=N'@IDTargetRecordOUT INT OUTPUT'
SET @Skript=N'INSERT INTO ' + @TabName + N'('
SELECT @SeznamAtributu = @SeznamAtributu + (CASE WHEN @SeznamAtributu<>N'' THEN N', ' ELSE N'' END) + N'[' + SC.Name + N']'
FROM syscolumns SC
WHERE SC.ID=OBJECT_ID(@TabName,N'U')
AND SC.iscomputed=0
AND SC.xtype NOT IN(36)  --uniqueidentifier
AND COLUMNPROPERTY(SC.id, SC.name, 'IsIdentity') = 0
AND PATINDEX(N'%' + SC.Name + N'%,', @IgnoreAtrList)=0
SET @Skript=@Skript + @SeznamAtributu + N')'
SET @SeznamAtributu=REPLACE(@SeznamAtributu, @ReplaceAtr1, @ReplaceValue1)
SET @SeznamAtributu=REPLACE(@SeznamAtributu, @ReplaceAtr2, @ReplaceValue2)
SET @Skript=@Skript + NCHAR(13) + NCHAR(10) + N'SELECT ' + @SeznamAtributu + NCHAR(13) + NCHAR(10) + N'FROM ' + @TabName + NCHAR(13) + NCHAR(10) + N'WHERE ' + @WhereSysSourceTab
SET @Skript=@Skript + NCHAR(13) + NCHAR(10) + N'SET @IDTargetRecordOUT = SCOPE_IDENTITY()'
EXEC sp_executesql @Skript, @ParmDefinition, @IDTargetRecordOUT=@IDTargetRecord OUTPUT
GO

