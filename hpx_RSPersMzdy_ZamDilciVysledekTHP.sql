USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_ZamDilciVysledekTHP]    Script Date: 26.06.2025 9:22:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_ZamDilciVysledekTHP]
	@IDZam INT
	,@Vypocet SMALLINT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description: Stanoveni mzdy - napocet dilcich vysledku za zamestnance - algoritmus THP
-- =============================================

/* deklarace */

DECLARE @Podminka1 NVARCHAR(255);
DECLARE @Podminka2 NVARCHAR(255);
DECLARE @Podminka3 NVARCHAR(255);
DECLARE @Podminka4 NVARCHAR(255);
DECLARE @Podminka5 NVARCHAR(255);
DECLARE @Podminka6 NVARCHAR(255);
DECLARE @Podminka7 NVARCHAR(255);
DECLARE @Podminka8 NVARCHAR(255);

DECLARE @Stredisko NVARCHAR(30);

DECLARE @ExecSQL NVARCHAR(4000);
DECLARE @CRLF CHAR(2);

SET @CRLF=CHAR(13)+CHAR(10);

SELECT
	@Stredisko = Z.Stredisko
FROM TabCisZam Z
	INNER JOIN Tabx_RSPersMzdy_PoziceStredisko P ON Z.Stredisko = P.Stredisko
WHERE Z.ID = @IDZam

-- matice Kategorie Urovne
DECLARE @KategorieUrovne TABLE(
	Kategorie SMALLINT
	,Uroven SMALLINT);
INSERT INTO @KategorieUrovne(Kategorie,Uroven)
VALUES(1,1),(1,2),(1,3),(2,1),(2,2),(2,3),(3,1),(3,2),(3,3),(4,1),(4,2),(4,3);

/* funkční tělo procedury */

-- napocet dle souladu
INSERT INTO Tabx_RSPersMzdy_DilciVysledek(
	IDZam
	,Vypocet
	,Kategorie
	,Uroven
	,PP_Vysledek
	,Z_Vysledek
	,Vysledek)
SELECT
	@IDZam
	,@Vypocet
	,Kategorie = PP_Kat
	,Uroven = PP_Uroven
	,PP_Vysledek = COALESCE(SUM(PP_Priorita),0.)
	,Z_Vysledek = COALESCE(SUM(CASE WHEN Soulad = 1 THEN PP_Priorita ELSE 0. END),0.)
	,Vysledek = CASE WHEN SUM(PP_Priorita) > 0.
					THEN (SUM(CASE WHEN Soulad = 1 THEN PP_Priorita ELSE 0. END) / SUM(PP_Priorita)) * 100.
					ELSE 0.
				END
FROM Tabx_RSPersMzdy_SouladDovednosti
WHERE IDZam = @IDZam
	AND Vypocet = @Vypocet
GROUP BY PP_Kat, PP_Uroven;

-- doplneni radku, ktere pozice nevyzaduje
INSERT INTO Tabx_RSPersMzdy_DilciVysledek(
	IDZam
	,Vypocet
	,Kategorie
	,Uroven
	,PP_Vysledek
	,Z_Vysledek
	,Vysledek)
SELECT
	@IDZam
	,@Vypocet
	,T.Kategorie
	,T.Uroven
	,0.
	,0.
	,0.
FROM @KategorieUrovne T
WHERE NOT EXISTS(SELECT * FROM Tabx_RSPersMzdy_DilciVysledek 
					WHERE IDZam = @IDZam
						AND Vypocet = @Vypocet
						AND Kategorie = T.Kategorie
						AND Uroven = T.Uroven);

-- nascitani bodu a naplneni
	WITH V as (
		SELECT
		Kategorie
		,Vysledek_U1 = SUM(CASE WHEN Uroven = 1 THEN Vysledek ELSE 0. END)
		,Vysledek_U2 = SUM(CASE WHEN Uroven = 2 THEN Vysledek ELSE 0. END)
		,Vysledek_U3 = SUM(CASE WHEN Uroven = 3 THEN Vysledek ELSE 0. END)
		FROM Tabx_RSPersMzdy_DilciVysledek
		WHERE IDZam = @IDZam
			AND Vypocet = @Vypocet
		GROUP BY Kategorie
		)
	,B as (
		SELECT
			Kategorie
			,Body = COALESCE((SELECT MAX(Hodnoceni_Body)
							FROM hvw_RSPersMzdy_PoziceHodnoceniAll
							WHERE (@Stredisko IS NULL OR Stredisko = @Stredisko)
								AND Hodnoceni_U1 <= V.Vysledek_U1
								AND Hodnoceni_U2 <= V.Vysledek_U2
								AND Hodnoceni_U3 <= V.Vysledek_U3)
						,0)
		FROM V
		)
	INSERT INTO Tabx_RSPersMzdy_PoziceZarazeniZam(
		IDZam
		,Vypocet
		,Body_K1
		,Body_K2
		,Body_K3
		,Body_K4)
	VALUES(
		@IDZam
		,@Vypocet
		,COALESCE((SELECT Body FROM B WHERE Kategorie = 1),0)
		,COALESCE((SELECT Body FROM B WHERE Kategorie = 2),0)
		,COALESCE((SELECT Body FROM B WHERE Kategorie = 3),0)
		,COALESCE((SELECT Body FROM B WHERE Kategorie = 4),0)
		);


--  * Vyhodnoceni podminek zarazeni na pozice

	SELECT @Podminka1 = CAST(STUFF(
						(
						CASE WHEN Podminka_K1 IS NOT NULL THEN N' AND Body_K1' + Podminka_K1 ELSE N'' END
						+ CASE WHEN Podminka_K2 IS NOT NULL THEN N' AND Body_K2' + Podminka_K2 ELSE N'' END
						+ CASE WHEN Podminka_K3 IS NOT NULL THEN N' AND Body_K3' + Podminka_K3 ELSE N'' END
						+ CASE WHEN Podminka_K4 IS NOT NULL THEN N' AND Body_K4' + Podminka_K4 ELSE N'' END
						)
						,1,5,N'') as NVARCHAR(255))
	FROM Tabx_RSPersMzdy_Pozice
	WHERE Poradi = 1;

	SELECT @Podminka2 = CAST(STUFF(
						(
						CASE WHEN Podminka_K1 IS NOT NULL THEN N' AND Body_K1' + Podminka_K1 ELSE N'' END
						+ CASE WHEN Podminka_K2 IS NOT NULL THEN N' AND Body_K2' + Podminka_K2 ELSE N'' END
						+ CASE WHEN Podminka_K3 IS NOT NULL THEN N' AND Body_K3' + Podminka_K3 ELSE N'' END
						+ CASE WHEN Podminka_K4 IS NOT NULL THEN N' AND Body_K4' + Podminka_K4 ELSE N'' END
						)
						,1,5,N'') as NVARCHAR(255))
	FROM Tabx_RSPersMzdy_Pozice
	WHERE Poradi = 2;

	SELECT @Podminka3 = CAST(STUFF(
						(
						CASE WHEN Podminka_K1 IS NOT NULL THEN N' AND Body_K1' + Podminka_K1 ELSE N'' END
						+ CASE WHEN Podminka_K2 IS NOT NULL THEN N' AND Body_K2' + Podminka_K2 ELSE N'' END
						+ CASE WHEN Podminka_K3 IS NOT NULL THEN N' AND Body_K3' + Podminka_K3 ELSE N'' END
						+ CASE WHEN Podminka_K4 IS NOT NULL THEN N' AND Body_K4' + Podminka_K4 ELSE N'' END
						)
						,1,5,N'') as NVARCHAR(255))
	FROM Tabx_RSPersMzdy_Pozice
	WHERE Poradi = 3;

	SELECT @Podminka4 = CAST(STUFF(
						(
						CASE WHEN Podminka_K1 IS NOT NULL THEN N' AND Body_K1' + Podminka_K1 ELSE N'' END
						+ CASE WHEN Podminka_K2 IS NOT NULL THEN N' AND Body_K2' + Podminka_K2 ELSE N'' END
						+ CASE WHEN Podminka_K3 IS NOT NULL THEN N' AND Body_K3' + Podminka_K3 ELSE N'' END
						+ CASE WHEN Podminka_K4 IS NOT NULL THEN N' AND Body_K4' + Podminka_K4 ELSE N'' END
						)
						,1,5,N'') as NVARCHAR(255))
	FROM Tabx_RSPersMzdy_Pozice
	WHERE Poradi = 4;

	SELECT @Podminka5 = CAST(STUFF(
						(
						CASE WHEN Podminka_K1 IS NOT NULL THEN N' AND Body_K1' + Podminka_K1 ELSE N'' END
						+ CASE WHEN Podminka_K2 IS NOT NULL THEN N' AND Body_K2' + Podminka_K2 ELSE N'' END
						+ CASE WHEN Podminka_K3 IS NOT NULL THEN N' AND Body_K3' + Podminka_K3 ELSE N'' END
						+ CASE WHEN Podminka_K4 IS NOT NULL THEN N' AND Body_K4' + Podminka_K4 ELSE N'' END
						)
						,1,5,N'') as NVARCHAR(255))
	FROM Tabx_RSPersMzdy_Pozice
	WHERE Poradi = 5;


	SELECT @Podminka6 = CAST(STUFF(
						(
						CASE WHEN Podminka_K1 IS NOT NULL THEN N' AND Body_K1' + Podminka_K1 ELSE N'' END
						+ CASE WHEN Podminka_K2 IS NOT NULL THEN N' AND Body_K2' + Podminka_K2 ELSE N'' END
						+ CASE WHEN Podminka_K3 IS NOT NULL THEN N' AND Body_K3' + Podminka_K3 ELSE N'' END
						+ CASE WHEN Podminka_K4 IS NOT NULL THEN N' AND Body_K4' + Podminka_K4 ELSE N'' END
						)
						,1,5,N'') as NVARCHAR(255))
	FROM Tabx_RSPersMzdy_Pozice
	WHERE Poradi = 6;

	SELECT @Podminka7 = CAST(STUFF(
						(
						CASE WHEN Podminka_K1 IS NOT NULL THEN N' AND Body_K1' + Podminka_K1 ELSE N'' END
						+ CASE WHEN Podminka_K2 IS NOT NULL THEN N' AND Body_K2' + Podminka_K2 ELSE N'' END
						+ CASE WHEN Podminka_K3 IS NOT NULL THEN N' AND Body_K3' + Podminka_K3 ELSE N'' END
						+ CASE WHEN Podminka_K4 IS NOT NULL THEN N' AND Body_K4' + Podminka_K4 ELSE N'' END
						)
						,1,5,N'') as NVARCHAR(255))
	FROM Tabx_RSPersMzdy_Pozice
	WHERE Poradi = 7;

	SELECT @Podminka8 = CAST(STUFF(
						(
						CASE WHEN Podminka_K1 IS NOT NULL THEN N' AND Body_K1' + Podminka_K1 ELSE N'' END
						+ CASE WHEN Podminka_K2 IS NOT NULL THEN N' AND Body_K2' + Podminka_K2 ELSE N'' END
						+ CASE WHEN Podminka_K3 IS NOT NULL THEN N' AND Body_K3' + Podminka_K3 ELSE N'' END
						+ CASE WHEN Podminka_K4 IS NOT NULL THEN N' AND Body_K4' + Podminka_K4 ELSE N'' END
						)
						,1,5,N'') as NVARCHAR(255))
	FROM Tabx_RSPersMzdy_Pozice
	WHERE Poradi = 8;

	SET @ExecSQL = N'UPDATE Tabx_RSPersMzdy_PoziceZarazeniZam SET ' + @CRLF +
	N'	Splnuje_P1 = CASE WHEN ' + ISNULL(@Podminka1,N'0=1') + N' THEN 1 ELSE 0 END' + @CRLF +
	N'	,Splnuje_P2 = CASE WHEN ' + ISNULL(@Podminka2,N'0=1') + N' THEN 1 ELSE 0 END' + @CRLF +
	N'	,Splnuje_P3 = CASE WHEN ' + ISNULL(@Podminka3,N'0=1') + N' THEN 1 ELSE 0 END' + @CRLF +
	N'	,Splnuje_P4 = CASE WHEN ' + ISNULL(@Podminka4,N'0=1') + N' THEN 1 ELSE 0 END' + @CRLF +
	N'	,Splnuje_P5 = CASE WHEN ' + ISNULL(@Podminka5,N'0=1') + N' THEN 1 ELSE 0 END' + @CRLF +
	N'	,Splnuje_P6 = CASE WHEN ' + ISNULL(@Podminka6,N'0=1') + N' THEN 1 ELSE 0 END' + @CRLF +
	N'	,Splnuje_P7 = CASE WHEN ' + ISNULL(@Podminka7,N'0=1') + N' THEN 1 ELSE 0 END' + @CRLF +
	N'	,Splnuje_P8 = CASE WHEN ' + ISNULL(@Podminka8,N'0=1') + N' THEN 1 ELSE 0 END' + @CRLF +
	N'WHERE IDZam = @IDZam' + @CRLF +
	N'	AND Vypocet = @Vypocet;';

	EXEC sp_executesql
		@ExecSQL
		,N'@IDZam INT, @Vypocet SMALLINT'
		,@IDZam
		,@Vypocet;
		

-- * dosazeni pozice

UPDATE Tabx_RSPersMzdy_PoziceZarazeniZam SET
	Pozice = CASE WHEN Splnuje_P8 = 1 THEN 8
				ELSE CASE WHEN Splnuje_P7 = 1 THEN 7
					ELSE CASE WHEN Splnuje_P6 = 1 THEN 6
						ELSE CASE WHEN Splnuje_P5 = 1 THEN 5
							ELSE CASE WHEN Splnuje_P4 = 1 THEN 4
								ELSE CASE WHEN Splnuje_P3 = 1 THEN 3
									ELSE CASE WHEN Splnuje_P2 = 1 THEN 2
										ELSE CASE WHEN Splnuje_P1 = 1 THEN 1
											END
										END
									END
								END
							END
						END
					END
				END
WHERE IDZam = @IDZam
	AND Vypocet = @Vypocet;

IF (SELECT Pozice FROM Tabx_RSPersMzdy_PoziceZarazeniZam WHERE IDZam = @IDZam AND Vypocet = @Vypocet) IS NULL
	BEGIN
		RAISERROR (N'Výpočet THP - informace: Dosažené body nezařazují zaměstnance na žádnou pozici!',16,1);
		RETURN;
	END;
GO

