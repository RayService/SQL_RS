USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_ZamVypocet]    Script Date: 26.06.2025 9:29:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_ZamVypocet]
	@Algoritmus NVARCHAR(3)
	,@ID INT			-- ID v Tabx_RSPersMzdy_Vypocet
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description: Stanoveni mzdy - vypocet - kontejner pro zam
-- =============================================

/* deklarace */
DECLARE @IDPP INT;
DECLARE @Pozice NVARCHAR(3);
DECLARE @IDZam INT;
DECLARE @Vypocet SMALLINT;

SELECT 
	@IDZam = IDZam
	,@Vypocet = Vypocet
FROM Tabx_RSPersMzdy_Vypocet
WHERE ID = @ID;

BEGIN TRY

	/* kontroly */

	-- kontroly konfigurace
	EXEC [dbo].[hpx_RSPersMzdy_Kontrola];
	
	-- povolene hodnoty algoritmu
	IF @Algoritmus IS NULL OR @Algoritmus NOT IN (N'TK',N'THP',N'TPV')
		BEGIN
			RAISERROR (N'Neplatná volba algoritmu výpočtu',16,1);
			RETURN;
		END;
	
	/* funkční tělo procedury */
	-- * výmaz údajů nápočtu - všude
	DELETE FROM Tabx_RSPersMzdy_SouladDovednosti WHERE IDZam = @IDZam AND Vypocet = @Vypocet;
	DELETE FROM Tabx_RSPersMzdy_DilciVysledek WHERE IDZam = @IDZam AND Vypocet = @Vypocet;
	DELETE FROM Tabx_RSPersMzdy_PoziceZarazeniZam WHERE IDZam = @IDZam AND Vypocet = @Vypocet;
		
	-- * výpočet - společná pro všechny algoritmy
	
	-- pracovni pozice vypoctu
	SELECT
		@IDPP = IDPP
	FROM TabCisZam Z
		INNER JOIN TabObsazeniPracovnichPozic OPP ON Z.ID = OPP.IDZam		-- (Z)Obsazeni prac. pozic
												AND CAST(OPP.PlatnostOd as DATE) <=  CAST(GETDATE() as DATE) 
												AND (CAST(OPP.PlatnostDo as DATE) >= CAST(GETDATE() as DATE) OR OPP.PlatnostDo IS NULL)
	WHERE Z.ID = @IDZam;
	
	IF @IDPP IS NULL
		BEGIN
			RAISERROR (N'Zaměstnanec nemá přiřazenu platnou pracovní pozici',16,1);
			RETURN;
		END;
	
	-- soulad dovednosti PP <> Zam
	EXEC dbo.hpx_RSPersMzdy_ZamSouladDovednosti
		@Algoritmus = @Algoritmus
		,@IDZam = @IDZam
		,@Vypocet = @Vypocet;
	
	
	-- * výpočty za jednotlivé algoritmy
	
	-- THP
	IF @Algoritmus = N'THP'
		BEGIN
		
			-- nejsou zadany pozadovane dovednosti
			IF NOT EXISTS(SELECT * FROM Tabx_RSPersMzdy_PozadovaneDovednosti
						WHERE IDZam = @IDZam
							AND Vypocet = @Vypocet)
				BEGIN
					RAISERROR (N'Výpočet THP - chyba: Zaměstnanec nemá pro daný druh výpočtu vybrány požadované dovednosti',16,1);
					RETURN;
				END;
			
			-- dílčí výsledek
			EXEC dbo.hpx_RSPersMzdy_ZamDilciVysledek
				@Algoritmus = @Algoritmus
				,@IDZam = @IDZam
				,@Vypocet = @Vypocet;
			
			-- final
			SELECT
				@Pozice = P.Kod
			FROM Tabx_RSPersMzdy_PoziceZarazeniZam ZZ
				INNER JOIN Tabx_RSPersMzdy_Pozice P ON ZZ.Pozice = P.Poradi
			WHERE ZZ.IDZam = @IDZam
				AND ZZ.Vypocet = @Vypocet;
				
			IF @Pozice IS NULL
				BEGIN
					RAISERROR (N'Výpočet THP - chyba: Neznámý identifikátor pozice',16,1);
					RETURN;
				END;
				
			UPDATE C SET
				C.IDPP = @IDPP
				,C.Algoritmus = @Algoritmus
				,C.Pozice = @Pozice
				,C.TypMzdy = 0 -- mesicny
				,C.Mzda = Z.THP_MzdaFix
				,C.DatZmeny = GETDATE()
				,C.Zmenil = SUSER_SNAME()
			FROM Tabx_RSPersMzdy_Vypocet C
				INNER JOIN Tabx_RSPersMzdy_Pozice Z ON Z.Kod = @Pozice
			WHERE C.IDZam = @IDZam
				AND C.Vypocet = @Vypocet;
				
		END;
	
	-- TK
	IF @Algoritmus = N'TK'
		BEGIN
			
			-- dílčí výsledek
			EXEC dbo.hpx_RSPersMzdy_ZamDilciVysledek
				@Algoritmus = @Algoritmus
				,@IDZam = @IDZam
				,@Vypocet = @Vypocet;
			
			-- final
			SELECT
				@Pozice = P.Kod
			FROM Tabx_RSPersMzdy_PoziceZarazeniZam ZZ
				INNER JOIN Tabx_RSPersMzdy_Pozice P ON ZZ.Pozice = P.Poradi
			WHERE ZZ.IDZam = @IDZam
				AND ZZ.Vypocet = @Vypocet;
				
			IF @Pozice IS NULL
				BEGIN
					RAISERROR (N'Výpočet TK - chyba: Neznámý identifikátor pozice',16,1);
					RETURN;
				END;
				
			UPDATE C SET
				C.IDPP = @IDPP
				,C.Algoritmus = @Algoritmus
				,C.Pozice = @Pozice
				,C.TypMzdy = 1 -- hodinova
				,C.Mzda = ROUND((Z.TK_Mzda_Hodinova + Z.TK_Mzda_K1 + Z.TK_Mzda_K2 + Z.TK_Mzda_K3),2)
				,C.DatZmeny = GETDATE()
				,C.Zmenil = SUSER_SNAME()
			FROM Tabx_RSPersMzdy_Vypocet C
				INNER JOIN Tabx_RSPersMzdy_PoziceZarazeniZam Z ON C.IDZam = C.IDZam AND C.Vypocet = Z.Vypocet
			WHERE C.IDZam = @IDZam
				AND C.Vypocet = @Vypocet;
			
		END;

END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	RAISERROR (@ErrorMessage,16,1);
	RETURN;
END CATCH;
GO

