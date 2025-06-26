USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_Validace_ulozenka]    Script Date: 26.06.2025 15:02:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_Validace_ulozenka]
@IdZasilky INT,
@KontrolovatPouzeBaliky BIT = 0
AS
SET NOCOUNT ON
DECLARE @ErrorMsg NVARCHAR(4000), @ErrorMsgParam1 NVARCHAR(255), @TEMPStr NVARCHAR(255)
DECLARE @Language INT
SET @Language=(SELECT Jazyk FROM TabUziv WHERE LoginName=SUSER_SNAME())
IF @Language IS NULL SET @Language=1
IF @KontrolovatPouzeBaliky=0
BEGIN
IF (SELECT COUNT(*) FROM Tabx_BalikobotBaliky WHERE IdZasilky=@IdZasilky)=0
BEGIN
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('2264E29D-BC51-40B9-AD12-7BC5A22AEBD6', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF (SELECT ISNULL(rec_name, '') FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)=''
BEGIN
SET @ErrorMsgParam1='"' + dbo.hfx_Balikobot_ReturnText('8FBDD54F-0273-4E5E-B8C0-40FCB4684F21', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT) + '"'
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('F26E2F23-F45F-43EC-82C4-D27171D9E0F3', @Language, @ErrorMsgParam1, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF (SELECT ISNULL(rec_country, '') FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)=''
BEGIN
SET @ErrorMsgParam1='"' + dbo.hfx_Balikobot_ReturnText('FB2F8A22-E4E6-4C31-A268-385CA890FF2E', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT) + '"'
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('F26E2F23-F45F-43EC-82C4-D27171D9E0F3', @Language, @ErrorMsgParam1, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF (SELECT Dobirka FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)=1
BEGIN
IF (SELECT cod_price FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky)=0
BEGIN
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('833EDC31-2F27-45BF-AF12-419CB1118D14', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF (SELECT ISNULL(cod_currency, '') FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky)=''
BEGIN
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('F3A35AA3-03FF-4628-AEF9-4CEE0F444FD3', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF EXISTS(SELECT * FROM Tabx_BalikobotBaliky WHERE IdZasilky=@IdZasilky AND ISNULL(vs, '')='')
BEGIN
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('0E6B6458-BC0B-4356-8F87-03FDB7647C19', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
END
IF (SELECT service_type FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky) IN('1', '5', '10', '11', '7')
BEGIN
IF (SELECT branch_id FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky) IS NULL
BEGIN
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('E274C66C-8F95-4D94-8372-3A4378EFCD04', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
END
END
GO

