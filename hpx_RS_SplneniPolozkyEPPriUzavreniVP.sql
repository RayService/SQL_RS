USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_SplneniPolozkyEPPriUzavreniVP]    Script Date: 30.06.2025 8:49:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_SplneniPolozkyEPPriUzavreniVP] @IDPrikaz INT
AS
SET NOCOUNT ON;

BEGIN
--DECLARE @IDPrikaz INT=267657
DECLARE @IDPol INT
DECLARE @IDKmen INT
DECLARE @IDZakazka INT
DECLARE @CisloZakazky NVARCHAR(15)
DECLARE @MnoPol NUMERIC(19,2)

SET @IDKmen=(SELECT tp.IDTabKmen FROM TabPrikaz tp WHERE tp.ID=@IDPrikaz)
SET @MnoPol=(SELECT tp.kusy_zad FROM TabPrikaz tp WHERE tp.ID=@IDPrikaz)
SET @IDZakazka=(SELECT tp.IDZakazka FROM TabPrikaz tp WHERE tp.ID=@IDPrikaz)
SET @CisloZakazky=(SELECT tz.CisloZakazky FROM TabZakazka tz WHERE tz.ID=@IDZakazka)
SET @IDPol=(
SELECT TOP 1 tpz.ID
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
WHERE
(tdz.RadaDokladu LIKE N'%480%')AND
(tkz.ID=@IDKmen)AND
(tpz.CisloZakazky=@CisloZakazky)AND
((tpz.Mnozstvi - tpz.MnOdebrane)>0)AND
(tpz.Mnozstvi=@MnoPol)
AND(tpz.SplnenoPol=0)
ORDER BY tpze._EXT_RS_PromisedStockingDate ASC)
--SELECT @IDPol
UPDATE TabPohybyZbozi SET SplnenoPol=1 WHERE ID=@IDPol
END;
GO

