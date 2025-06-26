USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_VratKontaktyProZasilku]    Script Date: 26.06.2025 15:06:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_VratKontaktyProZasilku]
@IdDoklad INT,
@IdKonfigurace INT,
@CisloOrg INT,
@rec_firm NVARCHAR(255) OUT,
@rec_name NVARCHAR(255) OUT,
@rec_phone NVARCHAR(50) OUT,
@rec_email NVARCHAR(100) OUT,
@rec_street NVARCHAR(100) OUT,
@rec_city NVARCHAR(100) OUT,
@rec_zip NVARCHAR(20) OUT,
@rec_country NVARCHAR(100) OUT,
@PrepsatZpusobDohledaniKontaktu TINYINT=NULL,
@rec_region NVARCHAR(50) = NULL OUT
AS
DECLARE @IdOrganizace INT
, @ZpusobDohledaniKontaktu TINYINT
, @IDVztahKOsOrg INT
, @IDCisKOs INT, @IDCisKOs_MU_B INT, @IDCisKOs_MU_P INT, @IDCisKOs_OD_B INT, @IDCisKOs_OD_P INT
, @IdOdberatel INT
, @IdMistoUrceni INT
, @IDVztahOrgKOs_MU_B INT, @IDVztahOrgKOs_MU_P INT, @IDVztahOrgKOs_OD_B INT, @IDVztahOrgKOs_OD_P INT
IF @IdKonfigurace IS NULL
SET @IdKonfigurace=dbo.hfx_Balikobot_VratKonfiguraci(@IdDoklad)
SET @ZpusobDohledaniKontaktu=(SELECT ZpusobDohledaniKontaktu FROM Tabx_BalikobotKonfigurace WHERE ID=@IdKonfigurace)
IF (@ZpusobDohledaniKontaktu=99)AND(OBJECT_ID('dbo.epx_Balikobot_VratKontaktyProZasilku', 'P') IS NULL)
SET @ZpusobDohledaniKontaktu=0
IF @PrepsatZpusobDohledaniKontaktu IS NOT NULL
  SET @ZpusobDohledaniKontaktu=@PrepsatZpusobDohledaniKontaktu
IF @ZpusobDohledaniKontaktu=0
BEGIN
IF @CisloOrg IS NULL
SET @CisloOrg=(SELECT ISNULL(MistoUrceni, CisloOrg) FROM TabDokladyZbozi WHERE ID=@IdDoklad)
SET @IdOrganizace=(SELECT ID FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
SET @rec_firm=(SELECT O.Firma FROM TabCisOrg O WHERE ID=@IdOrganizace)
SET @rec_name=(SELECT ISNULL(VCisKOsVztahOrgKOs.Jmeno, '') + ' ' + VCisKOsVztahOrgKOs.Prijmeni
FROM TabVztahOrgKOs
LEFT OUTER JOIN TabCisKOs VCisKOsVztahOrgKOs ON VCisKOsVztahOrgKOs.ID=TabVztahOrgKOs.IDCisKOs
WHERE (TabVztahOrgKOs.IDOrg=@IdOrganizace) AND (TabVztahOrgKOs.Prednastaveno=1))
SET @rec_phone=(SELECT Spojeni FROM TabKontakty WHERE IDOrg=@IdOrganizace AND IDVztahKOsOrg IS NULL AND Prednastaveno=1 AND Druh=2)
IF @rec_phone IS NULL
SET @rec_phone=(SELECT Spojeni FROM TabKontakty WHERE IDOrg=@IdOrganizace AND IDVztahKOsOrg IS NULL AND Prednastaveno=1 AND Druh=1)
SET @rec_email=(SELECT Spojeni FROM TabKontakty WHERE IDOrg=@IdOrganizace AND IDVztahKOsOrg IS NULL AND Prednastaveno=1 AND Druh=6)
SET @IDVztahKOsOrg=(SELECT ID FROM TabVztahOrgKOs WHERE IDOrg=@IdOrganizace AND Prednastaveno=1)
SET @IDCisKOs=(SELECT IDCisKOs FROM TabVztahOrgKOs WHERE IDOrg=@IdOrganizace AND Prednastaveno=1)
IF @rec_phone IS NULL
BEGIN
SET @rec_phone=(SELECT Spojeni FROM TabKontakty WHERE IDVztahKOsOrg=@IDVztahKOsOrg AND Prednastaveno=1 AND Druh=2)
IF @rec_phone IS NULL
SET @rec_phone=(SELECT Spojeni FROM TabKontakty WHERE IDVztahKOsOrg=@IDVztahKOsOrg AND Prednastaveno=1 AND Druh=1)
IF @rec_phone IS NULL
SET @rec_phone=(SELECT Spojeni FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDCisKOs=@IDCisKOs AND Prednastaveno=1 AND Druh=2)
IF @rec_phone IS NULL
SET @rec_phone=(SELECT Spojeni FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDCisKOs=@IDCisKOs AND Prednastaveno=1 AND Druh=1)
END
IF @rec_email IS NULL
BEGIN
SET @rec_email=(SELECT Spojeni FROM TabKontakty WHERE IDVztahKOsOrg=@IDVztahKOsOrg AND Prednastaveno=1 AND Druh=6)
IF @rec_email IS NULL
SET @rec_email=(SELECT Spojeni FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDCisKOs=@IDCisKOs AND Prednastaveno=1 AND Druh=6)
END
SELECT @rec_street=UliceSCisly,
@rec_city=Misto,
@rec_zip=PSC,
@rec_country=ISNULL(IdZeme, 'CZ'),
@rec_region=NazevOkresu
FROM TabCisOrg
WHERE ID=@IdOrganizace
END
IF @ZpusobDohledaniKontaktu=1
BEGIN
IF @CisloOrg IS NOT NULL
SET @IdMistoUrceni=(SELECT ID FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
ELSE
BEGIN
SET @IdOdberatel=(SELECT ID FROM TabCisOrg WHERE CisloOrg=(SELECT CisloOrg FROM TabDokladyZbozi WHERE ID=@IdDoklad))
SET @IdMistoUrceni=(SELECT ID FROM TabCisOrg WHERE CisloOrg=(SELECT MistoUrceni FROM TabDokladyZbozi WHERE ID=@IdDoklad))
END
SET @IDVztahOrgKOs_MU_B=NULL
SET @IDVztahOrgKOs_MU_P=NULL
SET @IDVztahOrgKOs_OD_B=NULL
SET @IDVztahOrgKOs_OD_P=NULL
SET @IDCisKOs_MU_B=NULL
SET @IDCisKOs_OD_B=NULL
SET @IDCisKOs_MU_P=NULL
SET @IDCisKOs_OD_P=NULL
SELECT TOP 1 @IDVztahOrgKOs_MU_B=K.ID, @IDCisKOs_MU_B=K.IDCisKOs
FROM TabVztahOrgKOs K
LEFT OUTER JOIN TabVztahOrgKOs_EXT KE ON KE.ID=K.ID
WHERE K.IDOrg=@IdMistoUrceni AND KE._Balikobot_Prednastaveno=1
SELECT TOP 1 @IDVztahOrgKOs_OD_B=K.ID, @IDCisKOs_OD_B=K.IDCisKOs
FROM TabVztahOrgKOs K
LEFT OUTER JOIN TabVztahOrgKOs_EXT KE ON KE.ID=K.ID
WHERE K.IDOrg=@IdOdberatel AND KE._Balikobot_Prednastaveno=1
SELECT TOP 1 @IDVztahOrgKOs_MU_P=K.ID, @IDCisKOs_MU_P=K.IDCisKOs
FROM TabVztahOrgKOs K
WHERE K.IDOrg=@IdMistoUrceni AND K.Prednastaveno=1
SELECT TOP 1 @IDVztahOrgKOs_OD_P=K.ID, @IDCisKOs_OD_P=K.IDCisKOs
FROM TabVztahOrgKOs K
WHERE K.IDOrg=@IdOdberatel AND K.Prednastaveno=1
SET @rec_firm=(SELECT O.Firma FROM TabCisOrg O WHERE ID=ISNULL(@IdMistoUrceni, @IdOdberatel))
SET @rec_name=(SELECT ISNULL(Prijmeni, '') + N' ' + ISNULL(Jmeno, '') FROM TabCisKOs WHERE ID=ISNULL(@IDCisKOs_MU_B, ISNULL(@IDCisKOs_OD_B, ISNULL(@IDCisKOs_MU_P, @IDCisKOs_OD_P))))
IF ISNULL(@rec_name, '')=''
SET @rec_name=@rec_firm
SET @rec_street=(SELECT UliceSCisly FROM TabCisOrg WHERE ID=@IdMistoUrceni)
IF @rec_street IS NULL
SET @rec_street=(SELECT UliceSCisly FROM TabCisOrg WHERE ID=@IdOdberatel)
SET @rec_city=(SELECT Misto FROM TabCisOrg WHERE ID=@IdMistoUrceni)
IF @rec_city IS NULL
SET @rec_city=(SELECT Misto FROM TabCisOrg WHERE ID=@IdOdberatel)
SET @rec_zip=(SELECT PSC FROM TabCisOrg WHERE ID=@IdMistoUrceni)
IF @rec_zip IS NULL
SET @rec_zip=(SELECT PSC FROM TabCisOrg WHERE ID=@IdOdberatel)
SET @rec_country=(SELECT IdZeme FROM TabCisOrg WHERE ID=@IdMistoUrceni)
IF @rec_country IS NULL
SET @rec_country=(SELECT IdZeme FROM TabCisOrg WHERE ID=@IdOdberatel)
IF @rec_country IS NULL
SET @rec_country=N'CZ'
SET @rec_region=(SELECT NazevOkresu FROM TabCisOrg WHERE ID=@IdMistoUrceni)
IF ISNULL(@rec_region, '')=''
  SET @rec_region=(SELECT NazevOkresu FROM TabCisOrg WHERE ID=@IdOdberatel)
EXEC dbo.hpx_Balikobot_VratKontaktDleDruhu
  @IDCisKOs_MU_B=@IDCisKOs_MU_B,
  @IDCisKOs_OD_B=@IDCisKOs_OD_B,
  @IDCisKOs_MU_P=@IDCisKOs_MU_P,
  @IDCisKOs_OD_P=@IDCisKOs_OD_P,
  @IDVztahOrgKOs_MU_B=@IDVztahOrgKOs_MU_B,
  @IDVztahOrgKOs_MU_P=@IDVztahOrgKOs_MU_P,
  @IDVztahOrgKOs_OD_B=@IDVztahOrgKOs_OD_B,
  @IDVztahOrgKOs_OD_P=@IDVztahOrgKOs_OD_P,
  @IdMistoUrceni=@IdMistoUrceni,
  @IdOdberatel=@IdOdberatel,
  @Druh=2,
  @Spojeni=@rec_phone OUT
EXEC dbo.hpx_Balikobot_VratKontaktDleDruhu
  @IDCisKOs_MU_B=@IDCisKOs_MU_B,
  @IDCisKOs_OD_B=@IDCisKOs_OD_B,
  @IDCisKOs_MU_P=@IDCisKOs_MU_P,
  @IDCisKOs_OD_P=@IDCisKOs_OD_P,
  @IDVztahOrgKOs_MU_B=@IDVztahOrgKOs_MU_B,
  @IDVztahOrgKOs_MU_P=@IDVztahOrgKOs_MU_P,
  @IDVztahOrgKOs_OD_B=@IDVztahOrgKOs_OD_B,
  @IDVztahOrgKOs_OD_P=@IDVztahOrgKOs_OD_P,
  @IdMistoUrceni=@IdMistoUrceni,
  @IdOdberatel=@IdOdberatel,
  @Druh=6,
  @Spojeni=@rec_email OUT
END
IF @ZpusobDohledaniKontaktu=99
BEGIN
EXEC dbo.epx_Balikobot_VratKontaktyProZasilku
@IdDoklad=@IdDoklad,
@CisloOrg=@CisloOrg,
@rec_firm=@rec_firm OUT,
@rec_name=@rec_name OUT,
@rec_phone=@rec_phone OUT,
@rec_email=@rec_email OUT,
@rec_street=@rec_street OUT,
@rec_city=@rec_city OUT,
@rec_zip=@rec_zip OUT,
@rec_country=@rec_country OUT
END
GO

