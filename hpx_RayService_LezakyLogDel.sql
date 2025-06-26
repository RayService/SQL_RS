USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_LezakyLogDel]    Script Date: 26.06.2025 9:07:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Create date: 19.6.2012
-- Description:	Ležáky - Nápočet
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_LezakyLogDel]
	@ID INT					-- ID v hvw_RayService_LezakyLog
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @Obdobi NCHAR(6)
DECLARE @IDSklad NVARCHAR(30);
DECLARE @ExecSQL NVARCHAR(4000)
DECLARE @CRLF CHAR(2);

DECLARE @Rok SMALLINT;
DECLARE @Mesic TINYINT;

SET @CRLF=CHAR(13)+CHAR(10);

SELECT
	@Obdobi = Obdobi
	,@IDSklad = IDSklad
FROM Tabx_RayService_LezakyLog
WHERE ID = @ID;

SET @Rok = CAST(LEFT(@Obdobi,4) as SMALLINT);
SET @Mesic = CAST(RIGHT(@Obdobi,2) as TINYINT);

/* funkční tělo procedury */

-- vymažeme hodnoty
SET @ExecSQL = N'UPDATE C SET' + @CRLF +
'	C.M_' + @Obdobi + ' = NULL' + @CRLF +
'	,C.S_' + @Obdobi + ' = NULL' + @CRLF +
'	,C.A_' + @Obdobi + ' = NULL' + @CRLF +
'FROM Tabx_RayService_Lezaky C' + @CRLF +
'	INNER JOIN TabStavSkladu S ON C.ID = S.ID AND S.IDSklad = @IDSklad;'

EXEC sp_executesql
	@ExecSQL
	,N'@IDSklad NVARCHAR(30)'
	,@IDSklad;
	
-- vymyzeme hodnoty - radky
DELETE FROM Tabx_RayService_LezakyRadky
WHERE Rok = @Rok AND Mesic = @Mesic;
	
-- smažame záznam z logu
DELETE FROM Tabx_RayService_LezakyLog
WHERE ID = @ID;
GO

