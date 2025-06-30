USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_Validace_SDS]    Script Date: 30.06.2025 8:36:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_Validace_SDS]
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
IF (SELECT ISNULL(rec_email, '') FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)=''
BEGIN
SET @ErrorMsgParam1='"' + dbo.hfx_Balikobot_ReturnText('75BB554D-BA10-4354-BD8D-C24F94D3F043', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT) + '"'
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('F26E2F23-F45F-43EC-82C4-D27171D9E0F3', @Language, @ErrorMsgParam1, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF (SELECT ISNULL(rec_street, '') FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)=''
BEGIN
SET @ErrorMsgParam1='"' + dbo.hfx_Balikobot_ReturnText('28CA2AD8-EE73-486B-B62E-0165F0DB2C88', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT) + '"'
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('F26E2F23-F45F-43EC-82C4-D27171D9E0F3', @Language, @ErrorMsgParam1, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF (SELECT ISNULL(rec_city, '') FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)=''
BEGIN
SET @ErrorMsgParam1='"' + dbo.hfx_Balikobot_ReturnText('94D95621-DF72-48EC-99E0-18D4857994AB', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT) + '"'
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('F26E2F23-F45F-43EC-82C4-D27171D9E0F3', @Language, @ErrorMsgParam1, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF (SELECT ISNULL(rec_zip, '') FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)=''
BEGIN
SET @ErrorMsgParam1='"' + dbo.hfx_Balikobot_ReturnText('7692081A-E69C-4ED0-B662-B73198906FE7', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT) + '"'
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
IF (SELECT ISNULL(cod_price, 0) FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky)=0
BEGIN
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('18246056-304B-4629-A9FD-0E754D5C43E7', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
IF (SELECT ISNULL(cod_currency, '') FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky)=''
BEGIN
SET @ErrorMsg = dbo.hfx_Balikobot_ReturnText('F3A35AA3-03FF-4628-AEF9-4CEE0F444FD3', @Language, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
INSERT #TabExtKom(Poznamka) VALUES(@ErrorMsg)
END
END
END
GO

