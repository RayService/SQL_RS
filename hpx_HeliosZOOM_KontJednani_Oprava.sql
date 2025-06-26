USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_KontJednani_Oprava]    Script Date: 26.06.2025 9:36:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_HeliosZOOM_KontJednani_Oprava] @Predmet NVARCHAR(255),@DatumJednaniOd DATETIME,@DatumJednaniDo DATETIME,@Typ NVARCHAR(3),@Stav NVARCHAR(3),@Popis NTEXT,@CisloOrg INT,@ID INT
AS
DECLARE @PoradoveCislo INT,@SkladZbozi NVARCHAR(30)

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

IF @Typ  = N'nul' SET @Typ  = N'' 

IF @Stav  = N'nul' SET @Stav  = N'' 



UPDATE TabKontaktJednani SET
 Predmet = @Predmet,
 DatumJednaniOd = @DatumJednaniOd,
 DatumJednaniDo = @DatumJednaniDo,
 Popis = @Popis, 
 Typ = @Typ,
 Stav = @Stav,
 CisloOrg = @CisloOrg
WHERE ID = @ID
GO

