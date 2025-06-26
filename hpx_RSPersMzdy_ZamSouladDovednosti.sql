USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_ZamSouladDovednosti]    Script Date: 26.06.2025 9:21:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_ZamSouladDovednosti]
	@Algoritmus NVARCHAR(3)
	,@IDZam INT
	,@Vypocet SMALLINT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description: Stanoveni mzdy - napocet do tabulky Tabx_RSPersMzdy_SouladDovednosti za zam
-- =============================================

-- vymaz, pokud jsme nevymazali v predchozim kroku
IF EXISTS(SELECT * FROM Tabx_RSPersMzdy_SouladDovednosti WHERE IDZam = @IDZam AND Vypocet = @Vypocet)
	DELETE FROM Tabx_RSPersMzdy_SouladDovednosti WHERE IDZam = @IDZam AND Vypocet = @Vypocet;


-- * Naplneni daty

-- algotirmus THP
IF @Algoritmus = N'THP'
	BEGIN
	
		-- Soulad + Nesoulad
		INSERT INTO Tabx_RSPersMzdy_SouladDovednosti(
			IDZam
			,Vypocet
			,Algoritmus
			,IDPP
			,Soulad
			,PP_Kat
			,PP_KatID
			,PP_KatNazev
			,PP_DovednostID
			,PP_DovednostNazev
			,PP_Uroven
			,PP_UrovenID
			,PP_Priorita
			,Z_KatID
			,Z_KatNazev
			,Z_DovednostID
			,Z_DovednostNazev
			,Z_Uroven
			,Z_UrovenID)
		SELECT 
			IDZam = @IDZam
			,Vypocet = @Vypocet
			,Algoritmus = @Algoritmus
			,IDPP = OPP.IDPP
			
			,Soulad = CAST(1 as TINYINT) -- Soulad
			 
			,PP_Kat = KDE._RSPersMzdy_Kategorie
			,PP_KatID = KD.ID
			,PP_KatNazev = KD.Nazev
			,PP_DovednostID = DP.ZnalostID
			,PP_DovednostNazev = DC.Nazev
			,PP_Uroven = URPE._RSPersMzdy_Uroven
			,PP_UrovenID = URP.ID
			,PP_Priorita = [dbo].[hfx_RSPersMzdy_Txt2Num](PZP.Nazev)
			
			,Z_KatID = KZ.ID
			,Z_KatNazev = KZ.Nazev
			,Z_DovednostID = DZ.ZnalostID
			,Z_DovednostNazev = ZC.Nazev
			,Z_Uroven = URZE._RSPersMzdy_Uroven
			,Z_UrovenID = URZ.ID
		FROM TabCisZam Z
			INNER JOIN TabCisZamZnalosti DZ ON Z.ID = DZ.ZamestnanecId			-- Dovednosti Z
			INNER JOIN TabObsazeniPracovnichPozic OPP ON Z.ID = OPP.IDZam		-- (Z)Obsazeni prac. pozic
														AND CAST(OPP.PlatnostOd as DATE) <=  CAST(GETDATE() as DATE) 
														AND (CAST(OPP.PlatnostDo as DATE) >= CAST(GETDATE() as DATE) OR OPP.PlatnostDo IS NULL)
			INNER JOIN Tabx_RSPersMzdy_PozadovaneDovednosti PozD ON Z.ID = PozD.IDZam AND PozD.Vypocet = @Vypocet AND OPP.IDPP = PozD.IDPP	-- Pozadovane dovednosti
			INNER JOIN TabPracovniPozice PP ON OPP.IDPP = PP.ID 					-- (Z)Pracovni pozice
			INNER JOIN TabPracovniPoziceDetail DPP ON OPP.IDPP = DPP.IdHlavicka	-- Detail pracovni pozice
													AND DPP.Aktualni = 1
			INNER JOIN TabPersZnalostiCis ZC ON DZ.ZnalostId = ZC.ID				-- (Z)Dovednosti
			INNER JOIN TabPersZnalostiUrovenCis URZ ON DZ.UrovenID = URZ.ID		-- (Z)Uroven
			INNER JOIN TabPersZnalostiUrovenCis_EXT URZE ON URZ.ID = URZE.ID		-- (Z)Uroven_EXT
			INNER JOIN TabPersZnalostiKategorieCis KZ ON ZC.IDKategorie = KZ.ID	-- (Z)Kategorie
			LEFT JOIN TabPracovniPoziceDetailZnalosti DP ON PozD.IDPPDetailZnalosti = DP.ID	-- Dovednosti PP
			LEFT JOIN TabPersZnalostiCis DC ON DP.ZnalostId = DC.ID					-- (P)Dovednosti			
			LEFT JOIN TabPersZnalostiUrovenCis URP ON DP.UrovenID = URP.ID			-- (P)Uroven
			LEFT JOIN TabPersZnalostiUrovenCis_EXT URPE ON URP.ID = URPE.ID			-- (P)Uroven_EXT
			LEFT JOIN TabPersZnalostiKategorieCis KD ON DC.IDKategorie = KD.ID		-- (P)Kategorie
			LEFT JOIN TabPersZnalostiKategorieCis_EXT KDE ON KD.ID = KDE.ID			-- (P)Kategorie_EXT	
			LEFT JOIN TabPersZnalostiPrioritaCis PZP ON PZP.ID = DP.PrioritaID		-- (P)Priorita
			LEFT JOIN TabCisZamZnalosti_EXT DZE ON DZ.ID = DZE.ID					-- Dovednosti Z - EXT
		WHERE Z.ID = @IDZam
			AND DZ.ZnalostID = DP.ZnalostID
			AND DZ.UrovenId = DP.UrovenId
			AND (
					(@Vypocet = 0 AND ISNULL(DZE._RSPersMzdy_Simulace,2) = 2)
					OR
					(@Vypocet > 0 AND ISNULL(DZE._RSPersMzdy_Simulace,1) = 1)
				)
			AND KDE._RSPersMzdy_Kategorie IS NOT NULL
			AND (
				(@Algoritmus = N'TK' AND KDE._RSPersMzdy_AlgoritmusTK = 1)
				OR (@Algoritmus = N'THP' AND KDE._RSPersMzdy_AlgoritmusTHP = 1)
				OR (@Algoritmus = N'TPV' AND KDE._RSPersMzdy_AlgoritmusTPV = 1)	
				)
			AND URPE._RSPersMzdy_Uroven IS NOT NULL	
			
		UNION ALL
		
		SELECT 
			IDZam = Z.ID
			,Vypocet = @Vypocet
			,Algoritmus = @Algoritmus
			,IDPP = OPP.IDPP
			
			,Soulad = CAST(0 as TINYINT) -- Nesoulad
			
			,PP_Kat = KDE._RSPersMzdy_Kategorie
			,PP_KatID = KD.ID
			,PP_KatNazev = KD.Nazev
			,PP_DovednostID = DP.ZnalostID
			,PP_DovednostNazev = DC.Nazev
			,PP_Uroven = URPE._RSPersMzdy_Uroven
			,PP_UrovenID = URP.ID
			,PP_Priorita = [dbo].[hfx_RSPersMzdy_Txt2Num](PZP.Nazev)
			
			,Z_KatID = NULL
			,Z_KatNazev = NULL
			,Z_DovednostID = NULL
			,Z_DovednostNazev = NULL
			,Z_Uroven = NULL
			,Z_UrovenID = NULL
		FROM TabCisZam Z
			INNER JOIN TabObsazeniPracovnichPozic OPP ON Z.ID = OPP.IDZam		-- (Z)Obsazeni prac. pozic
														AND CAST(OPP.PlatnostOd as DATE) <=  CAST(GETDATE() as DATE) 
														AND (CAST(OPP.PlatnostDo as DATE) >= CAST(GETDATE() as DATE) OR OPP.PlatnostDo IS NULL)
			INNER JOIN Tabx_RSPersMzdy_PozadovaneDovednosti PozD ON Z.ID = PozD.IDZam AND PozD.Vypocet = @Vypocet AND OPP.IDPP = PozD.IDPP	-- Pozadovane dovednosti
			--INNER JOIN TabPracovniPozice PP ON OPP.IDPP = PP.ID 					-- (Z)Pracovni pozice
			--INNER JOIN TabPracovniPoziceDetail DPP ON OPP.IDPP = DPP.IdHlavicka	-- Detail pracovni pozice
			--										AND DPP.Aktualni = 1
			INNER JOIN TabPracovniPoziceDetailZnalosti DP ON PozD.IDPPDetailZnalosti = DP.ID	-- Dovednosti PP
			LEFT JOIN TabPersZnalostiCis DC ON DP.ZnalostId = DC.ID					-- (P)Dovednosti			
			LEFT JOIN TabPersZnalostiUrovenCis URP ON DP.UrovenID = URP.ID			-- (P)Uroven
			LEFT JOIN TabPersZnalostiUrovenCis_EXT URPE ON URP.ID = URPE.ID			-- (P)Uroven_EXT
			LEFT JOIN TabPersZnalostiKategorieCis KD ON DC.IDKategorie = KD.ID		-- (P)Kategorie
			LEFT JOIN TabPersZnalostiKategorieCis_EXT KDE ON KD.ID = KDE.ID			-- (P)Kategorie_EXT	
			LEFT JOIN TabPersZnalostiPrioritaCis PZP ON PZP.ID = DP.PrioritaID		-- (P)Priorita
		WHERE Z.ID = @IDZam
			AND NOT EXISTS(SELECT * FROM TabCisZamZnalosti DZ
							LEFT OUTER JOIN TabCisZamZnalosti_EXT DZE ON DZ.ID = DZE.ID
					WHERE DZ.ZamestnanecId = Z.ID AND DZ.ZnalostId = DP.ZnalostId AND DZ.UrovenId = DP.UrovenId
						AND (
								(@Vypocet = 0 AND ISNULL(DZE._RSPersMzdy_Simulace,2) = 2)
								OR
								(@Vypocet > 0 AND ISNULL(DZE._RSPersMzdy_Simulace,1) = 1)
							))
			AND KDE._RSPersMzdy_Kategorie IS NOT NULL
			AND (
				(@Algoritmus = N'TK' AND KDE._RSPersMzdy_AlgoritmusTK = 1)
				OR (@Algoritmus = N'THP' AND KDE._RSPersMzdy_AlgoritmusTHP = 1)
				OR (@Algoritmus = N'TPV' AND KDE._RSPersMzdy_AlgoritmusTPV = 1)	
				)
			AND URPE._RSPersMzdy_Uroven IS NOT NULL;
		
	END;

-- ostatni algoritmy - nejsou zavisle na vyberu pozadovanych dovednosti, ale simulace je mozna

IF @Algoritmus <> N'THP'
	BEGIN
	
		-- Soulad + Nesoulad
		INSERT INTO Tabx_RSPersMzdy_SouladDovednosti(
			IDZam
			,Vypocet
			,Algoritmus
			,IDPP
			,Soulad
			,PP_Kat
			,PP_KatID
			,PP_KatNazev
			,PP_DovednostID
			,PP_DovednostNazev
			,PP_Uroven
			,PP_UrovenID
			,PP_Priorita
			,Z_KatID
			,Z_KatNazev
			,Z_DovednostID
			,Z_DovednostNazev
			,Z_Uroven
			,Z_UrovenID)
		SELECT 
			IDZam = @IDZam
			,Vypocet = @Vypocet
			,Algoritmus = @Algoritmus
			,IDPP = OPP.IDPP
			
			,Soulad = CAST(1 as TINYINT) -- Soulad
			 
			,PP_Kat = KDE._RSPersMzdy_Kategorie
			,PP_KatID = KD.ID
			,PP_KatNazev = KD.Nazev
			,PP_DovednostID = DP.ZnalostID
			,PP_DovednostNazev = DC.Nazev
			,PP_Uroven = URPE._RSPersMzdy_Uroven
			,PP_UrovenID = URP.ID
			,PP_Priorita = [dbo].[hfx_RSPersMzdy_Txt2Num](PZP.Nazev)
			
			,Z_KatID = KZ.ID
			,Z_KatNazev = KZ.Nazev
			,Z_DovednostID = DZ.ZnalostID
			,Z_DovednostNazev = ZC.Nazev
			,Z_Uroven = URZE._RSPersMzdy_Uroven
			,Z_UrovenID = URZ.ID
		FROM TabCisZam Z
			INNER JOIN TabCisZamZnalosti DZ ON Z.ID = DZ.ZamestnanecId			-- Dovednosti Z
			INNER JOIN TabObsazeniPracovnichPozic OPP ON Z.ID = OPP.IDZam		-- (Z)Obsazeni prac. pozic
														AND CAST(OPP.PlatnostOd as DATE) <=  CAST(GETDATE() as DATE) 
														AND (CAST(OPP.PlatnostDo as DATE) >= CAST(GETDATE() as DATE) OR OPP.PlatnostDo IS NULL)
			INNER JOIN TabPracovniPozice PP ON OPP.IDPP = PP.ID 					-- (Z)Pracovni pozice
			INNER JOIN TabPracovniPoziceDetail DPP ON OPP.IDPP = DPP.IdHlavicka	-- Detail pracovni pozice
													AND DPP.Aktualni = 1
			LEFT JOIN TabPersZnalostiCis ZC ON DZ.ZnalostId = ZC.ID				-- (Z)Dovednosti
			LEFT JOIN TabPersZnalostiUrovenCis URZ ON DZ.UrovenID = URZ.ID		-- (Z)Uroven
			LEFT JOIN TabPersZnalostiUrovenCis_EXT URZE ON URZ.ID = URZE.ID		-- (Z)Uroven_EXT
			LEFT JOIN TabPersZnalostiKategorieCis KZ ON ZC.IDKategorie = KZ.ID	-- (Z)Kategorie
			LEFT JOIN TabPracovniPoziceDetailZnalosti DP ON DPP.ID = DP.DetailId	-- Dovednosti PP
			LEFT JOIN TabPersZnalostiCis DC ON DP.ZnalostId = DC.ID					-- (P)Dovednosti			
			LEFT JOIN TabPersZnalostiUrovenCis URP ON DP.UrovenID = URP.ID			-- (P)Uroven
			LEFT JOIN TabPersZnalostiUrovenCis_EXT URPE ON URP.ID = URPE.ID			-- (P)Uroven_EXT
			LEFT JOIN TabPersZnalostiKategorieCis KD ON DC.IDKategorie = KD.ID		-- (P)Kategorie
			LEFT JOIN TabPersZnalostiKategorieCis_EXT KDE ON KD.ID = KDE.ID			-- (P)Kategorie_EXT	
			LEFT JOIN TabPersZnalostiPrioritaCis PZP ON PZP.ID = DP.PrioritaID		-- (P)Priorita
			LEFT JOIN TabCisZamZnalosti_EXT DZE ON DZ.ID = DZE.ID					-- Dovednosti Z - EXT
		WHERE Z.ID = @IDZam
			AND DZ.ZnalostID = DP.ZnalostID
			AND DZ.UrovenId = DP.UrovenId
			AND (
					(@Vypocet = 0 AND DZE._RSPersMzdy_Simulace IS NULL)
					OR
					(@Vypocet > 0 AND ISNULL(DZE._RSPersMzdy_Simulace,1) = 1)
				)
			AND KDE._RSPersMzdy_Kategorie IS NOT NULL
			AND (
				(@Algoritmus = N'TK' AND KDE._RSPersMzdy_AlgoritmusTK = 1)
				OR (@Algoritmus = N'THP' AND KDE._RSPersMzdy_AlgoritmusTHP = 1)
				OR (@Algoritmus = N'TPV' AND KDE._RSPersMzdy_AlgoritmusTPV = 1)	
				)
			AND URPE._RSPersMzdy_Uroven IS NOT NULL	
			
		UNION ALL

		SELECT 
			IDZam = Z.ID
			,Vypocet = @Vypocet
			,Algoritmus = @Algoritmus
			,IDPP = OPP.IDPP
			
			,Soulad = CAST(0 as TINYINT) -- Nesoulad
			
			,PP_Kat = KDE._RSPersMzdy_Kategorie
			,PP_KatID = KD.ID
			,PP_KatNazev = KD.Nazev
			,PP_DovednostID = DP.ZnalostID
			,PP_DovednostNazev = DC.Nazev
			,PP_Uroven = URPE._RSPersMzdy_Uroven
			,PP_UrovenID = URP.ID
			,PP_Priorita = [dbo].[hfx_RSPersMzdy_Txt2Num](PZP.Nazev)
			
			,Z_KatID = NULL
			,Z_KatNazev = NULL
			,Z_DovednostID = NULL
			,Z_DovednostNazev = NULL
			,Z_Uroven = NULL
			,Z_UrovenID = NULL
		FROM TabCisZam Z
			INNER JOIN TabObsazeniPracovnichPozic OPP ON Z.ID = OPP.IDZam		-- (Z)Obsazeni prac. pozic
														AND CAST(OPP.PlatnostOd as DATE) <=  CAST(GETDATE() as DATE) 
														AND (CAST(OPP.PlatnostDo as DATE) >= CAST(GETDATE() as DATE) OR OPP.PlatnostDo IS NULL)
			INNER JOIN TabPracovniPozice PP ON OPP.IDPP = PP.ID 					-- (Z)Pracovni pozice
			INNER JOIN TabPracovniPoziceDetail DPP ON OPP.IDPP = DPP.IdHlavicka	-- Detail pracovni pozice
													AND DPP.Aktualni = 1
			INNER JOIN TabPracovniPoziceDetailZnalosti DP ON DPP.ID = DP.DetailId	-- Dovednosti PP
			LEFT JOIN TabPersZnalostiCis DC ON DP.ZnalostId = DC.ID					-- (P)Dovednosti			
			LEFT JOIN TabPersZnalostiUrovenCis URP ON DP.UrovenID = URP.ID			-- (P)Uroven
			LEFT JOIN TabPersZnalostiUrovenCis_EXT URPE ON URP.ID = URPE.ID			-- (P)Uroven_EXT
			LEFT JOIN TabPersZnalostiKategorieCis KD ON DC.IDKategorie = KD.ID		-- (P)Kategorie
			LEFT JOIN TabPersZnalostiKategorieCis_EXT KDE ON KD.ID = KDE.ID			-- (P)Kategorie_EXT	
			LEFT JOIN TabPersZnalostiPrioritaCis PZP ON PZP.ID = DP.PrioritaID		-- (P)Priorita
		WHERE Z.ID = @IDZam
			AND NOT EXISTS(SELECT * FROM TabCisZamZnalosti DZ
									LEFT OUTER JOIN TabCisZamZnalosti_EXT DZE ON DZ.ID = DZE.ID
							WHERE DZ.ZamestnanecId = Z.ID AND DZ.ZnalostId = DP.ZnalostId AND DZ.UrovenId = DP.UrovenId
								AND (
										(@Vypocet = 0 AND DZE._RSPersMzdy_Simulace IS NULL)
										OR
										(@Vypocet > 0 AND ISNULL(DZE._RSPersMzdy_Simulace,1) = 1)
									))
			AND KDE._RSPersMzdy_Kategorie IS NOT NULL
			AND (
				(@Algoritmus = N'TK' AND KDE._RSPersMzdy_AlgoritmusTK = 1)
				OR (@Algoritmus = N'THP' AND KDE._RSPersMzdy_AlgoritmusTHP = 1)
				OR (@Algoritmus = N'TPV' AND KDE._RSPersMzdy_AlgoritmusTPV = 1)	
				)
			AND URPE._RSPersMzdy_Uroven IS NOT NULL;
	
	END;
	
-- Sloupc Rn
WITH D as 
	(
		SELECT 
			ID
			,Rn_Kat = ROW_NUMBER() OVER(PARTITION BY PP_KatID ORDER BY PP_Kat ASC)
			,Rn_KatUroven = ROW_NUMBER() OVER(PARTITION BY PP_KatID, PP_UrovenID ORDER BY CASE WHEN Z_UrovenID IS NOT NULL THEN 0 ELSE 1 END ASC, PP_Uroven ASC)
		FROM Tabx_RSPersMzdy_SouladDovednosti
		WHERE IDZam = @IDZam
			AND Vypocet = @Vypocet
	)
UPDATE C SET
	Rn_Kat = D.Rn_Kat
	,Rn_KatUroven = D.Rn_KatUroven
FROM Tabx_RSPersMzdy_SouladDovednosti C
	INNER JOIN D ON C.ID = D.ID;
GO

