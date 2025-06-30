USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ValidaceEditoruVyrOperace]    Script Date: 30.06.2025 9:01:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RS_ValidaceEditoruVyrOperace]
  @ValidaceOK BIT,  -- 1 = tlačítko OK, 0 = tlačítko Storno
  @NovaVeta BIT,    -- 1 = validace nové věty, 0 = validace opravy
  @NovaVetaExt BIT  -- NULL = externí sloupce nejsou, 1 = nová věta externích informací, 0 = oprava
AS

--WITH Evidence AS (
--SELECT 
--prp.IDPrikaz AS IDPrikaz, prp.ID AS IDOper, tp.Rada AS Rada,tp.Prikaz AS Prikaz, prpe._EXT_B2ADIMARS_IdAssignedEmployee AS IDOsoby, prpe._OdpOsOp AS OdpOs
--FROM TabPrPostup prp
--LEFT OUTER JOIN TabPrikaz tp ON prp.IDPrikaz=tp.ID
--LEFT OUTER JOIN TabPrPostup_EXT prpe ON prpe.ID=prp.ID
--WHERE
--(prp.IDOdchylkyDo IS NULL)AND
--(prp.Splneno=0)AND
--(prp.nazev LIKE N'přezkoumání%')AND
--(tp.Rada=N'909')AND
--(tp.StavPrikazu=30)
----AND(prpe._EXT_B2ADIMARS_IdAssignedEmployee IS NOT NULL OR prpe._OdpOsOp IS NOT NULL)
----AND(prpe._OdpOsOp IS NULL)
--)
--SELECT ev.*--, OdpOsUk.Cislo, OdpOsUk.PrijmeniJmeno
--FROM Evidence ev
--LEFT OUTER JOIN TabCisZam OdpOsUk ON OdpOsUk.PrijmeniJmeno=ev.OdpOs
--LEFT OUTER JOIN TabCisZam OdpOsID ON OdpOsID.ID=ev.IDOsoby
--LEFT OUTER JOIN TabZamMzd mzd ON mzd.ZamestnanecId=OdpOsUk.ID AND mzd.IdObdobi=(SELECT ID FROM TabMzdObd WHERE Mesic=DATEPART(MONTH,GETDATE()) AND Rok=DATEPART(YEAR,GETDATE()))
--WHERE mzd.StavES=0
--ORDER BY ev.OdpOs ASC

DECLARE @IDOperace INT
SET @IDOperace=(SELECT ID FROM #TempDefForm_Validace)
IF EXISTS (SELECT prp.ID
			FROM TabPrikaz tp
			LEFT OUTER JOIN TabPrPostup prp ON prp.IDPrikaz=tp.ID
			LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tp.IDTabKmen
			WHERE prp.ID=@IDOperace AND 
			(prp.IDOdchylkyDo IS NULL)AND
			(prp.Splneno=0)AND
			(tkz.Nazev1 LIKE N'přezkoumání%')AND
			(tp.Rada=N'909')AND
			(tp.StavPrikazu=30))
BEGIN
	DECLARE @IDOsoba INT
	DECLARE @OdpOsUk NVARCHAR(20)
	SELECT @IDOsoba=_EXT_B2ADIMARS_IdAssignedEmployee, @OdpOsUk=_OdpOsOp
	FROM #TempDefForm_Validace_EXT

	--nejsou-li ani jedna - upozornit dotazem
	IF @IDOsoba IS NULL AND @OdpOsUk IS NULL
	BEGIN
		SELECT 2, N'Nejsou vyplněny odpovědné osoby, neva?.', N'_EXT_B2ADIMARS_IdAssignedEmployee'
		RETURN
	END;


	--dotažení ID osoby dle odpovědné osoby úkolu
	IF @IDOsoba IS NULL AND @OdpOsUk IS NOT NULL
	BEGIN
		--dotáhneme IDOsoby dle odpovědné osoby. Toto může zhučet kvůli nenalezení jednoznačné vazby. V tom případě vynadat, fokus na políčko.
		--zjistíme možný problém
		DECLARE @Pocet INT, @IDOsoby INT
		;
		WITH Zam AS (
		SELECT tcz.ID AS ID, tcz.PrijmeniJmeno AS PrijmeniJmeno, COUNT(tcz.PrijmeniJmeno) OVER (PARTITION BY tcz.PrijmeniJmeno ORDER BY tcz.PrijmeniJmeno ASC) AS Pocet
		FROM TabCisZam tcz
		LEFT OUTER JOIN TabZamMzd mzd ON mzd.ZamestnanecId=tcz.ID AND mzd.IdObdobi=(SELECT ID FROM TabMzdObd WHERE Mesic=DATEPART(MONTH,GETDATE()) AND Rok=DATEPART(YEAR,GETDATE()))
		WHERE mzd.StavES=0 AND tcz.PrijmeniJmeno=@OdpOsUk
		)
		SELECT @Pocet=Zam.Pocet, @IDOsoby=Zam.ID
		FROM Zam

		IF @Pocet<>1
		BEGIN
		SELECT 1, N'Nepodařilo se nalézt odpovědnou osobu (ID), nutno doplnit ručně.', N'_EXT_B2ADIMARS_IdAssignedEmployee'
		RETURN
		END;

		--SET @IDOsoba=(
		--SELECT tcz.ID
		--FROM TabCisZam tcz
		--LEFT OUTER JOIN TabZamMzd mzd ON mzd.ZamestnanecId=tcz.ID AND mzd.IdObdobi=(SELECT ID FROM TabMzdObd WHERE Mesic=DATEPART(MONTH,GETDATE()) AND Rok=DATEPART(YEAR,GETDATE()))
		--WHERE mzd.StavES=0 AND tcz.PrijmeniJmeno=@OdpOsUk)

		--pokud není problém, dotáhneme IDOsoby
		UPDATE prpe SET _EXT_B2ADIMARS_IdAssignedEmployee=@IDOsoby
		FROM TabPrPostup prp
		LEFT OUTER JOIN TabPrPostup_EXT prpe ON prpe.ID=prp.ID
		WHERE prp.ID=@IDOperace
	END;

	--dotažení odpovědné osoby úkolu dle ID osoby
	IF @IDOsoba IS NOT NULL AND @OdpOsUk IS NULL
	BEGIN
	DECLARE @OdpOsoUkolu NVARCHAR(255)
		SET @OdpOsoUkolu=NULL
		SET @OdpOsoUkolu=(
		SELECT tcz.PrijmeniJmeno
		FROM TabCisZam tcz
		WHERE tcz.ID=@IDOsoba)
		--pokud není problém, dotáhneme IDOsoby
		UPDATE prpe SET _OdpOsOp=@OdpOsoUkolu
		FROM TabPrPostup prp
		LEFT OUTER JOIN TabPrPostup_EXT prpe ON prpe.ID=prp.ID
		WHERE prp.ID=@IDOperace
	END;
END;
GO

