USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_Kontrola]    Script Date: 26.06.2025 9:18:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_Kontrola]
	@Algoritmus NVARCHAR(3) = NULL
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - Kontrola vstupního nastavení
-- =============================================

-- ** Kontrola obecných nastavení

-- Kategorie - označení v _RSPersMzdy_Kategorie
IF (SELECT COUNT(*)
	FROM TabPersZnalostiKategorieCis_EXT E
		INNER JOIN (VALUES (1),(2),(3),(4)) as T(Cislo) ON E._RSPersMzdy_Kategorie = T.Cislo) < 4
	BEGIN
		RAISERROR ('Chyba konfigurace: Kategorie dovedností - Označení kategorie: neurčeny 4 požadované kategorie',16,1);
		RETURN;
	END;

-- Priorita na dovednostech pracovni pozice není numerická
IF EXISTS(SELECT*
		FROM TabPracovniPoziceDetail PD
			INNER JOIN TabPracovniPoziceDetailZnalosti PZ ON PD.ID = PZ.DetailId
			INNER JOIN TabPersZnalostiPrioritaCis PR ON PZ.PrioritaId = PR.ID
			INNER JOIN TabPersZnalostiCis D ON PZ.ZnalostId = D.ID
			INNER JOIN TabPersZnalostiKategorieCis K ON D.IDKategorie = K.ID
			INNER JOIN TabPersZnalostiKategorieCis_EXT KE ON K.ID = KE.ID
		WHERE PD.Aktualni = 1
			AND KE._RSPersMzdy_Kategorie IN (1,2,3,4)
			AND dbo.hfx_RSPersMzdy_Txt2Num(PR.Nazev) IS NULL)
	BEGIN
		RAISERROR ('Chyba konfigurace: Dovednosti pracovní pozice - Priorita: není číselného charakteru (obsahuje textové znaky)',16,1);
		RETURN;
	END;
GO

