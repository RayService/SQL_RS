USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_ReseniHeO_ZakNaPolozky]    Script Date: 26.06.2025 8:52:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Propsání zakázky z dokladu na položky
-- =============================================
CREATE PROCEDURE [dbo].[hpx_ReseniHeO_ZakNaPolozky]
	@KontrolovatZak BIT		-- Kontrolovat existenci hodnoty v poli Zakázka na hlavičce: 1-ano / 0-ne
	,@PrepisovatZak BIT		-- Přepisovat  zadanou hodnotu zakázky na položce hodnotou na hlavičce: 1-ano / 0-ne
	,@ZobrazitInfo BIT		-- Zobrazit informační okno s výsledkem akce: 1-ano / 0-ne
	,@IDDoklad INT
AS
SET NOCOUNT ON;

/* deklarace */
DECLARE @ZakazkaDoklad NVARCHAR(15);
DECLARE @IDPolozka INT;
DECLARE @ZakazkaPolozka NVARCHAR(15);
DECLARE @Tucne NCHAR(1);

SET @Tucne = CHAR(1);

/* kontroly */

-- * Doklad je realizován
IF (SELECT DatRealizace FROM TabDokladyZbozi WHERE ID = @IDDoklad) IS NOT NULL
	BEGIN
		IF @ZobrazitInfo = 1
			RAISERROR ('Dokladům ve stavu %sRealizováno%s nelze údaje měnit!',16,1,@Tucne,@Tucne);
		RETURN;
	END;
	
-- * Kontrola hodnot na dokladu
SELECT 
	@ZakazkaDoklad = CisloZakazky
FROM TabDokladyZbozi WHERE ID = @IDDoklad;

-- * Prazdna hodnota zakazky
IF @KontrolovatZak = 1 AND @ZakazkaDoklad IS NULL
	BEGIN
		RAISERROR ('Hlavička dokladu %sneobsahuje zakázku%s. Operaci nelze provést!',16,1,@Tucne,@Tucne);
		RETURN;
	END;

-- * Doklad nema polozky
IF NOT EXISTS (SELECT * FROM TabPohybyZbozi WHERE IDDoklad = @IDDoklad)
	BEGIN
		RAISERROR ('Doklad %sneobsahuje žádné položky%s. Operaci nelze provést!',16,1,@Tucne,@Tucne);
		RETURN;
	END;

/* funkční tělo procedury */

DECLARE CurPolozky CURSOR LOCAL FAST_FORWARD FOR
	SELECT 
		ID
		,CisloZakazky
	FROM TabPohybyZbozi WHERE IDDoklad = @IDDoklad;
OPEN CurPolozky;
FETCH NEXT FROM CurPolozky INTO @IDPolozka, @ZakazkaPolozka;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru
			
			UPDATE TabPohybyZbozi SET 
				CisloZakazky = CASE WHEN ((@ZakazkaPolozka IS NOT NULL AND @PrepisovatZak = 1) OR (@ZakazkaDoklad IS NOT NULL AND @ZakazkaPolozka IS NULL)) THEN @ZakazkaDoklad ELSE CisloZakazky END
			WHERE ID = @IDPolozka;
			
			IF @ZobrazitInfo = 1
				BEGIN

					INSERT INTO #TabExtKom(Poznamka)
					SELECT (SkupZbo + N' ' + RegCis + N' - ' + Nazev1) FROM TabPohybyZbozi WHERE ID = @IDPolozka;
					
					INSERT INTO #TabExtKom(Poznamka)
					SELECT (N'   ' + CASE WHEN ((@ZakazkaPolozka IS NOT NULL AND @PrepisovatZak = 1) OR (@ZakazkaDoklad IS NOT NULL AND @ZakazkaPolozka IS NULL)) THEN N'ok - přiřazena zakázka ' + @ZakazkaDoklad ELSE N'x - ponechána původní zakázka ' + @ZakazkaPolozka END);
					
				END;
				
			-- konec akce v kurzoru
		FETCH NEXT FROM CurPolozky INTO @IDPolozka, @ZakazkaPolozka;
		END;
CLOSE CurPolozky;
DEALLOCATE CurPolozky;


GO

