USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_ZamDilciVysledekTK]    Script Date: 26.06.2025 9:28:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_ZamDilciVysledekTK]
	@IDZam INT
	,@Vypocet SMALLINT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description: Stanoveni mzdy - napocet dilcich vysledku za zamestnance - algoritmus TK
-- =============================================

/* deklarace */
DECLARE @IDPP INT;
DECLARE @HodnotaBodu NUMERIC(19,6);
DECLARE @HodinovaMzda NUMERIC(19,6);


-- matice Kategorie
DECLARE @Kategorie TABLE(
	Kategorie SMALLINT);
INSERT INTO @Kategorie(Kategorie)
VALUES(1),(2),(3)

-- hodnoty pro výpočet
SELECT
	@IDPP = OPP.IDPP
	,@HodnotaBodu = PPE._RSPersMzdy_HodnotaBoduTK
	,@HodinovaMzda = PPE._RSPersMzdy_MzdaTK
FROM TabCisZam Z
	INNER JOIN TabObsazeniPracovnichPozic OPP ON Z.ID = OPP.IDZam		-- (Z)Obsazeni prac. pozic
											AND CAST(OPP.PlatnostOd as DATE) <=  CAST(GETDATE() as DATE) 
											AND (CAST(OPP.PlatnostDo as DATE) >= CAST(GETDATE() as DATE) OR OPP.PlatnostDo IS NULL)
	INNER JOIN TabPracovniPozice_EXT PPE ON OPP.IDPP = PPE.ID
WHERE Z.ID = @IDZam;


/* kontroly */

-- neznámá hodnota bodu
IF COALESCE(@HodnotaBodu,0.) = 0.
	BEGIN
		RAISERROR (N'Výpočet TK - chyba: Pracovní pozice nemá zadánu hodnotu bodu (TK)!',16,1);
		RETURN;
	END;
	
-- neznámá hodinová mzda
IF COALESCE(@HodinovaMzda,0.) = 0.
	BEGIN
		RAISERROR (N'Výpočet TK - chyba: Pracovní pozice nemá zadánu hodinovou mzdu (TK)!',16,1);
		RETURN;
	END;
	
/* funkční tělo procedury */

-- napocet dle souladu
INSERT INTO Tabx_RSPersMzdy_DilciVysledek(
	IDZam
	,Vypocet
	,Kategorie
	,PP_Vysledek
	,Z_Vysledek
	,Vysledek)
SELECT
	@IDZam
	,@Vypocet
	,Kategorie = PP_Kat
	,PP_Vysledek = COALESCE(SUM(PP_Priorita),0.)
	,Z_Vysledek = COALESCE(SUM(CASE WHEN Soulad = 1 THEN PP_Priorita ELSE 0. END),0.)
	,Vysledek = COALESCE(SUM(CASE WHEN Soulad = 1 THEN PP_Priorita ELSE 0. END),0.)
FROM Tabx_RSPersMzdy_SouladDovednosti
WHERE IDZam = @IDZam
	AND Vypocet = @Vypocet
GROUP BY PP_Kat;

-- doplneni radku za kategorie, ktere pozice nevyzaduje
INSERT INTO Tabx_RSPersMzdy_DilciVysledek(
	IDZam
	,Vypocet
	,Kategorie
	,PP_Vysledek
	,Z_Vysledek
	,Vysledek)
SELECT
	@IDZam
	,@Vypocet
	,T.Kategorie
	,0.
	,0.
	,0.
FROM @Kategorie T
WHERE NOT EXISTS(SELECT * FROM Tabx_RSPersMzdy_DilciVysledek 
					WHERE IDZam = @IDZam
						AND Vypocet = @Vypocet
						AND Kategorie = T.Kategorie
						AND Uroven IS NULL);

-- zarazeni
INSERT INTO Tabx_RSPersMzdy_PoziceZarazeniZam(
	IDZam
	,Vypocet
	,TK_Mzda_Hodinova
	,TK_Mzda_K1
	,TK_Mzda_K2
	,TK_Mzda_K3
	,TK_HodnotaBodu)
SELECT
	@IDZam
	,@Vypocet
	,@HodinovaMzda
	,COALESCE((SELECT Vysledek FROM Tabx_RSPersMzdy_DilciVysledek WHERE IDZam = @IDZam AND Vypocet = @Vypocet AND Kategorie = 1),0.) * @HodnotaBodu
	,COALESCE((SELECT Vysledek FROM Tabx_RSPersMzdy_DilciVysledek WHERE IDZam = @IDZam AND Vypocet = @Vypocet AND Kategorie = 2),0.) * @HodnotaBodu
	,COALESCE((SELECT Vysledek FROM Tabx_RSPersMzdy_DilciVysledek WHERE IDZam = @IDZam AND Vypocet = @Vypocet AND Kategorie = 3),0.) * @HodnotaBodu
	,@HodnotaBodu;
	
-- zarazeni na pozici
UPDATE C SET
	C.Pozice = (SELECT MAX(Poradi) FROM Tabx_RSPersMzdy_Pozice WHERE (C.TK_Mzda_Hodinova + C.TK_Mzda_K1 + C.TK_Mzda_K2 + C.TK_Mzda_K3) BETWEEN TK_Od AND TK_Do)
FROM Tabx_RSPersMzdy_PoziceZarazeniZam C
WHERE IDZam = @IDZam
	AND Vypocet = @Vypocet;
	
IF (SELECT Pozice FROM Tabx_RSPersMzdy_PoziceZarazeniZam WHERE IDZam = @IDZam AND Vypocet = @Vypocet) IS NULL
	BEGIN
		RAISERROR (N'Výpočet TK - informace: Dosažená mzda nezařazuje zaměstnance na žádnou pozici!',16,1);
		RETURN;
	END;
GO

