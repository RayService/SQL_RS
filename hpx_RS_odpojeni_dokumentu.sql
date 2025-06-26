USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_odpojeni_dokumentu]    Script Date: 26.06.2025 13:09:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_odpojeni_dokumentu] @kontrola BIT, @ID INT
AS
IF @kontrola=1
BEGIN
DECLARE @Oznacenych SMALLINT, @Aktualni SMALLINT
-- Počet řádků a aktuálně zpracovávaný řádek načteme do proměnných
SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM'
SELECT @Aktualni = MAX(Cislo) FROM #TabExtKomPar WHERE Popis = 'PRECHOD'
-- Smažeme při prvním průchodu možná existující původní vybrané záznamy
IF @Aktualni = 1 OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
   DELETE FROM OznaceneRadky WHERE Ident = @@SPID
-- Při každém průchodu vložíme do tabulky pro označené řádky potřebné atributy
INSERT INTO OznaceneRadky(ID,Ident) VALUES(@ID,@@SPID)

-- Samotné tělo procedury při průchodu posledním záznamem
IF @Aktualni = @Oznacenych OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
BEGIN
DELETE
FROM TabDokumVazba
WHERE IdTab IN (SELECT ID FROM OznaceneRadky WHERE Ident=@@SPID) AND IdDok=@ID AND IdentVazby=8
END

END;
GO

