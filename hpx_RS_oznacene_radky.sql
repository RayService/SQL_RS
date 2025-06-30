USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_oznacene_radky]    Script Date: 30.06.2025 9:02:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_oznacene_radky] @ID INT
AS
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
--testovací select
SELECT * FROM OznaceneRadky WHERE Ident = @@SPID
END
GO

