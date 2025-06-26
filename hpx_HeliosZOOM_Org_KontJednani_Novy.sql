USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_Org_KontJednani_Novy]    Script Date: 26.06.2025 9:38:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_HeliosZOOM_Org_KontJednani_Novy] @Kategorie NVARCHAR(3),@Predmet NVARCHAR(255),@DatumJednaniOd DATETIME,@DatumJednaniDo DATETIME,@Typ NVARCHAR(3),@Stav NVARCHAR(3),@Popis NTEXT,@IdOrg INT
AS
DECLARE @PoradoveCislo INT,@SkladZbozi NVARCHAR(30), @CisloOrg INT

DECLARE @Hlaska NVARCHAR(255)

IF ISNULL(@Predmet ,N'') = N''
 BEGIN
  SET @Hlaska = dbo.hfx_TranslateString(N'8F76F6A3-F4FD-4D0B-BD82-C59AD4ABDC52')
  IF @Hlaska IS NOT NULL
   BEGIN
    RAISERROR(@Hlaska, 16,1)
	RETURN
   END
 END

 SELECT @CisloOrg=TabCisOrg.CisloOrg FROM TabCisOrg WHERE ID=@IdOrg 


IF EXISTS(SELECT ID FROM TabKontaktJednani WHERE Kategorie = @Kategorie)
 SELECT @PoradoveCislo = MAX(PoradoveCislo)+1  FROM TabKontaktJednani WHERE Kategorie = @Kategorie
ELSE
 SET @PoradoveCislo = 1

SELECT @SkladZbozi = SkladZbozi FROM TabKategKontJed WHERE Cislo = @Kategorie


INSERT INTO TabKontaktJednani
  (PoradoveCislo, Kategorie, Predmet, DatumJednaniOd, DatumJednaniDo, Popis, Typ, Stav, DruhVystupu, Utvar, MistoKonani, CisloOrg, BlokovaniEditoru)
VALUES
  (@PoradoveCislo, @Kategorie, @Predmet, @DatumJednaniOd, @DatumJednaniDo, @Popis, @Typ, @Stav, N'', @SkladZbozi, N'', @CisloOrg, null)
GO

