USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_aktualizace_nazev1_kmen]    Script Date: 26.06.2025 13:57:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_aktualizace_nazev1_kmen]
@kontrola1 BIT,
@kontrola2 BIT,
@kontrola3 BIT,
@kontrola4 BIT,
@kontrola5 BIT,
@kontrola6 BIT,
@kontrola7 BIT,
@ID INT
AS
IF @kontrola1=1
BEGIN
UPDATE TabPohybyZbozi SET Nazev1 = tkz.Nazev1
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
WHERE tpz.ID = @ID
END;
IF @kontrola2=1
BEGIN
UPDATE TabPohybyZbozi SET Nazev2=tkz.Nazev2
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
WHERE tpz.ID=@ID
END;
IF @kontrola3=1
BEGIN
UPDATE TabPohybyZbozi SET Nazev3=tkz.Nazev3
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
WHERE tpz.ID=@ID
END;
IF @kontrola4=1
BEGIN
UPDATE TabPohybyZbozi SET Nazev4=tkz.Nazev4
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
WHERE tpz.ID=@ID
END;
IF @kontrola5=1
BEGIN
UPDATE TabPohybyZbozi SET SkupZbo=tkz.SkupZbo
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
WHERE tpz.ID=@ID
END;
IF @kontrola6=1
BEGIN
UPDATE TabPohybyZbozi SET RegCis=tkz.RegCis
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
WHERE tpz.ID=@ID
END;
IF @kontrola7=1
BEGIN
UPDATE TabPohybyZbozi SET SKP=tkz.SKP
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT tss.IDKmenZbozi FROM TabStavSkladu tss WHERE tss.ID=tpz.IDZboSklad)
WHERE tpz.ID=@ID
END;

IF (@kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0 AND @kontrola6=0 AND @kontrola7=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

