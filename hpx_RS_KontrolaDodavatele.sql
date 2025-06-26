USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KontrolaDodavatele]    Script Date: 26.06.2025 15:40:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KontrolaDodavatele]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS
DECLARE @IDOrg INT;
DECLARE @JeDodavatel BIT;
DECLARE @_typ_dodavatele NVARCHAR(20);
SET @IDOrg=(SELECT ID FROM #TempDefForm_Validace)
SET @JeDodavatel=(SELECT JeDodavatel FROM #TempDefForm_Validace)
SET @_typ_dodavatele=(SELECT ISNULL(_typ_dodavatele,'') FROM #TempDefForm_Validace_EXT)
--IF EXISTS (SELECT * FROM #TempDefFormInfo WHERE BrowseID=1)
BEGIN
IF @JeDodavatel=1 AND @_typ_dodavatele=''
BEGIN
  SELECT 1, N'Pole "Typ dodavatele" musí být vyplněno!', N'_typ_dodavatele'
  RETURN
END
END;

--MŽ, 20.12.2024
--Pouze při ukládání OK jde takový automat nastavit. Akorát co v případě, kdy tam již něco bude vyplněno a bude to jinak? Nebo co když země nebude vyplněna?
--když něco bude vyplněno, pak vždy přepiš dle zadání (když HEO pole IdZeme= česká/slovenská republika, pak CZ, jinak ANJ), pokud nic nebude pak ANJ
DECLARE @Jazyk NVARCHAR(15);
DECLARE @IdZeme NVARCHAR(3);
SET @Jazyk=(SELECT Jazyk FROM #TempDefForm_Validace)
SET @IdZeme=(SELECT IdZeme FROM #TempDefForm_Validace)
IF @IdZeme IN ('CZ','SK')
BEGIN
UPDATE TabCisOrg SET Jazyk=NULL WHERE ID=@IDOrg
END;
IF (@IdZeme NOT IN ('CZ','SK') OR @IdZeme='')
BEGIN
UPDATE TabCisOrg SET Jazyk='AJ' WHERE ID=@IDOrg
END;
GO

