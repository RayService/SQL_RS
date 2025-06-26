USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NABKontrolaRadaSklad]    Script Date: 26.06.2025 13:56:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NABKontrolaRadaSklad]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @IDNab INT;
DECLARE @DruhPohybuZbo TINYINT;
DECLARE @MenaDok NVARCHAR(3);
DECLARE @CisloOrg INT;
DECLARE @MenaOrg NVARCHAR(3);
DECLARE @ZemeOrg NVARCHAR(3);
DECLARE @KurzNab NUMERIC(19,6);
DECLARE @MenaNab NVARCHAR(3);

IF EXISTS (SELECT * FROM #TempDefFormInfo WHERE BrowseID=27)
BEGIN
IF EXISTS(SELECT*
			FROM #TempDefForm_Validace 
			JOIN TabDokladyZbozi NAB ON NAB.ID=#TempDefForm_Validace.ID
			WHERE #TempDefForm_Validace.ID = NAB.ID AND (NAB.IDSklad='10000115' AND NAB.RadaDokladu IN ('340','350')))
BEGIN
  RAISERROR(N'Nelze založit tuto řadu NAB na tomto skladu!', 16, 1)
  RETURN
END
END;
GO

