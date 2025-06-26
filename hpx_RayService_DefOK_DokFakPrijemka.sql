USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_DefOK_DokFakPrijemka]    Script Date: 26.06.2025 8:38:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Create date: 15.2.2012
-- Description:	Dotažení externího atributu Dodavatelská faktura na zdrojovou příjemku
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_DefOK_DokFakPrijemka]
	@IDDoklad INT		-- ID Dokladu v TabDokladyZbozi
AS
SET NOCOUNT ON
/* deklarace */
DECLARE @Pr TABLE(ID INT NOT NULL)

/* funkční tělo procedury */
-- naplníme tabulku s ID zdrojových Příjemek
INSERT INTO @Pr(ID)
SELECT DISTINCT PP.IDDoklad
FROM TabPohybyZbozi P
	INNER JOIN TabPohybyZbozi PP ON P.IDOldPolozka = PP.ID AND PP.DruhPohybuZbo = 0
WHERE P.IDDoklad = @IDDoklad
	AND P.DruhPohybuZbo = 18

-- jsou zdrojové výdejky
IF EXISTS(SELECT * FROM @Pr)
	BEGIN
		-- založíme externí info
		INSERT INTO TabDokladyZbozi_EXT(ID)
		SELECT ID FROM @Pr as T
		WHERE NOT EXISTS(SELECT * FROM TabDokladyZbozi_EXT WHERE ID = T.ID)
		
		-- aktualizujeme
		UPDATE C SET
			C._dod_fak_vyfa = Z.DodFak
		FROM TabDokladyZbozi_EXT C
			INNER JOIN @Pr P ON C.ID = P.ID
			INNER JOIN TabDokladyZbozi Z ON Z.ID = @IDDoklad
	END
GO

