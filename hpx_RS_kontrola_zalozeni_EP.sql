USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_kontrola_zalozeni_EP]    Script Date: 26.06.2025 10:39:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_kontrola_zalozeni_EP]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @IDEP INT;
DECLARE @Sklad NVARCHAR(30);
DECLARE @RadaDokladu NVARCHAR(3);
SET @IDEP=(SELECT ID FROM #TempDefForm_Validace)
SET @Sklad=(SELECT IDSklad FROM #TempDefForm_Validace)
SET @RadaDokladu=(SELECT RadaDokladu FROM #TempDefForm_Validace)
IF EXISTS (SELECT * FROM #TempDefFormInfo WHERE BrowseID=25)
BEGIN
IF EXISTS(SELECT*
			FROM #TempDefForm_Validace 
			JOIN TabDokladyZbozi EP ON EP.ID=#TempDefForm_Validace.ID
			WHERE #TempDefForm_Validace.ID = EP.ID AND ((EP.IDSklad='100' AND EP.RadaDokladu NOT IN ('400','410','411','440','450','472','499'))OR
														(EP.IDSklad='200' AND EP.RadaDokladu NOT IN ('420','430','474','480','499','491','492'))))
BEGIN
  RAISERROR(N'Nelze založit tuto řadu EP na tomto skladu!', 16, 1)
  RETURN
END
END;
/*pozastaveno 25.5.2022 na přání MoKol, znovu spuštěno 1.6.2022*/
BEGIN
IF EXISTS(SELECT*
			FROM #TempDefForm_Validace
			JOIN TabDokladyZbozi EP ON EP.ID=#TempDefForm_Validace.ID
			LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.IDDoklad=EP.ID
			LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WITH(NOLOCK) WHERE TabStavSkladu.ID=tpz.IDZboSklad)
			LEFT OUTER JOIN TabParKmZ pkm ON pkm.IDKmenZbozi = tkz.ID
			WHERE (pkm.TypDilce=1) AND (EP.IDSklad='200')-- AND (EP.ID=1376309)
			)
BEGIN
  RAISERROR(N'Pokoušíte se uložit EP s polotovarem a není to dobrý nápad!', 16, 1)
  RETURN
END
END;

BEGIN
--MŽ, 13.6.2023 přidána kontrola na měnu a kurz
--TabDokladyZbozi.Mena se nerovná CZK a zároveň Kurz = 1 => vyhoď hlášku - Zkontroluj zda máš dobře kurz
DECLARE @DruhPohybuZbo TINYINT;
DECLARE @MenaDok NVARCHAR(3);
DECLARE @IDNab INT;
DECLARE @CisloOrg INT;
DECLARE @MenaOrg NVARCHAR(3);
DECLARE @ZemeOrg NVARCHAR(3);
DECLARE @KurzNab NUMERIC(19,6);
DECLARE @MenaNab NVARCHAR(3);
SET @IDNab=(SELECT ID FROM #TempDefForm_Validace)
SET @DruhPohybuZbo=(SELECT DruhPohybuZbo FROM TabDokladyZbozi WHERE ID=@IDNab)
SET @MenaDok=(SELECT Mena FROM TabDokladyZbozi WHERE ID=@IDNab)
SET @CisloOrg=(SELECT CisloOrg FROM #TempDefForm_Validace)
SET @ZemeOrg=(SELECT IdZeme FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
SET @MenaOrg=(SELECT Mena FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
SET @KurzNab=(SELECT Kurz FROM TabDokladyZbozi WHERE ID=@IDNab)
SET @MenaNab=(SELECT Mena FROM TabDokladyZbozi WHERE ID=@IDNab)
IF ((@DruhPohybuZbo=9) AND (@MenaNab <> 'CZK' AND @KurzNab = 1))
BEGIN
  SELECT 2, N'Zkontroluj, zda máš dobře kurz.'
  RETURN
END;
END;
GO

