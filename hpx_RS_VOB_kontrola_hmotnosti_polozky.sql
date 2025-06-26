USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VOB_kontrola_hmotnosti_polozky]    Script Date: 26.06.2025 13:24:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VOB_kontrola_hmotnosti_polozky]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @IDDok INT;
DECLARE @DruhPohybuZbo TINYINT;
DECLARE @MenaDok NVARCHAR(3);
DECLARE @CisloOrg INT;
DECLARE @MenaOrg NVARCHAR(3);
DECLARE @VstupniCena TINYINT;
SET @IDDok=(SELECT ID FROM #TempDefForm_Validace);
SET @CisloOrg=(SELECT CisloOrg FROM #TempDefForm_Validace);
IF EXISTS (SELECT tpz.ID
		FROM TabPohybyZbozi tpz
		WHERE tpz.IDDoklad=@IDDok AND tpz.MJ='m' AND tpz.Hmotnost>80.0)
BEGIN
  SELECT 0, N'Pohlídat velikost cívky!'
  RETURN
END

/*
SELECT <typ 0|1|2: INT>, <text chyby: NVARCHAR>[, <nazev atributu pro fokus: NVARCHAR>]
Typ: 0 = informační hláška, 1 = chyba, 2 = dotaz (Ano/Ne/Storno - Ano pustí dál, Ne a Storno je jako chyba)
Sloupec s názvem atributu pro fokus není povinný, je možno ho vynechat.
*/
/*
Druh pohybu se rovná Objednávka vydaná nebo Expediční příkaz a zároveň TabCisOrg.Mena se nerovná CZK a zároveň Způsob zadávání ceny = JC bez daní => vyhoď hlášku - Zkontroluj zda máš správně způsob zadávání ceny
*/

IF @CisloOrg IS NULL
BEGIN
  SELECT 1, N'Nelze uložit doklad bez vyplněného pole Číslo organizace!','CisloOrg'
  RETURN
END
GO

