USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zamena_dokumentu_vazby]    Script Date: 26.06.2025 10:31:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zamena_dokumentu_vazby]
@ID INT
AS

DECLARE @Oznacenych SMALLINT, @Aktualni SMALLINT;
DECLARE @IDDok_puv INT;
DECLARE @IDDok_new INT;

-- Počet řádků a aktuálně zpracovávaný řádek načteme do proměnných
SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM'
SELECT @Aktualni = MAX(Cislo) FROM #TabExtKomPar WHERE Popis = 'PRECHOD'

-- Smažeme při prvním průchodu možná existující původní vybrané záznamy
IF @Aktualni = 1 OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
   DELETE FROM OznaceneRadky-- WHERE Ident = @@SPID

-- Při každém průchodu vložíme do tabulky pro označené řádky potřebné atributy
INSERT INTO OznaceneRadky(ID,Ident) VALUES(@ID,@@SPID)

-- Samotné tělo procedury při průchodu posledním záznamem
IF @Aktualni = @Oznacenych OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
BEGIN
SELECT @IDDok_puv = (SELECT MIN(ID) FROM OznaceneRadky);
SELECT @IDDok_new = (SELECT MAX(ID) FROM OznaceneRadky);
UPDATE TabDokumVazba SET IdDok = @IDDok_new WHERE IdDok = @IDDok_puv AND IdentVazby <> 1;

END
GO

