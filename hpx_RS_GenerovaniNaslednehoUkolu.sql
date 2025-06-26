USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniNaslednehoUkolu]    Script Date: 26.06.2025 14:24:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniNaslednehoUkolu]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS


-- Informační hláška

--ostrá deklarace
DECLARE @CisloOrg INT
DECLARE @PoradiNew NVARCHAR(4000)
DECLARE @Kategorie NVARCHAR(3)
DECLARE @NewID INT
DECLARE @Predmet NVARCHAR(255)

DECLARE @NazevOrg NVARCHAR(255)
DECLARE @DatSplneni DATETIME

SET @CisloOrg=(SELECT CisloOrg FROM TabCisOrg WHERE ID=(SELECT ID FROM #TempDefForm_Validace))
SET @DatSplneni=(SELECT TerminSplneni FROM #TempDefForm_Validace)

IF @DatSplneni IS NOT NULL
BEGIN
--vložíme úkol
INSERT INTO TabUkoly (Predmet, TerminZahajeni, Stav, HotovoProcent, CelkemHod, HotovoHod, IDKontaktJed, TypStart, StavStart, DruhVystupuStart, TypKonec, StavKonec, DruhVystupuKonec, CisloOrg)
VALUES (N'Zaslán etický kodex',GETDATE(),0,0,0,0,@NewID,N'',N'',N'',N'',N'',N'',@CisloOrg)
END;


IF EXISTS(SELECT*FROM #TempDefForm_Validace_EXT WHERE _Test1 = 1)
BEGIN
  SELECT 0, N'Byl založen nový úkol a odeslán mail dodavateli.'
END
GO

