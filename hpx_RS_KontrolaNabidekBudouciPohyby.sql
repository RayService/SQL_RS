USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KontrolaNabidekBudouciPohyby]    Script Date: 26.06.2025 13:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KontrolaNabidekBudouciPohyby]
AS
BEGIN
DELETE FROM Tabx_RS_KontrolaNabidekBudouciPohyby WHERE Autor=SUSER_SNAME()

INSERT INTO Tabx_RS_KontrolaNabidekBudouciPohyby (IDBudPoh, IDZakazka, IDKmeneZbozi)
SELECT bp.ID, bp.IDZakazka, bp.IDKmeneZbozi
FROM #TabExtKomID e WITH(NOLOCK)
LEFT OUTER JOIN #TabBudPOhyby bp WITH(NOLOCK) ON e.ID=bp.ID

UPDATE kn SET kn.CisloZakazky=tz.CisloZakazky
FROM Tabx_RS_KontrolaNabidekBudouciPohyby kn WITH(NOLOCK)
LEFT OUTER JOIN TabZakazka tz WITH(NOLOCK) ON tz.ID=kn.IDZakazka

UPDATE kn SET kn.CisloZakazkyPuv=tze._EXT_RS_puvodni_zakazka
FROM Tabx_RS_KontrolaNabidekBudouciPohyby kn WITH(NOLOCK)
LEFT OUTER JOIN TabZakazka tz WITH(NOLOCK) ON tz.ID=kn.IDZakazka
LEFT OUTER JOIN TabZakazka_EXT tze WITH(NOLOCK) ON tze.ID=tz.ID

--doplnit fajfku, kde je shodná zakázka s nějakou nabídkou k dané zakázce
UPDATE kn SET Nabidka=1
FROM Tabx_RS_KontrolaNabidekBudouciPohyby kn WITH(NOLOCK)
LEFT OUTER JOIN TabDokladyZbozi tdz WITH (NOLOCK) ON tdz.CisloZakazky=kn.CisloZakazky AND tdz.DruhPohybuZbo=11
LEFT OUTER JOIN TabPohybyZbozi tpz WITH (NOLOCK) ON tpz.IDDoklad=tdz.ID
WHERE tdz.CisloZakazky=kn.CisloZakazky AND kn.IDKmeneZbozi=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WITH(NOLOCK) WHERE TabStavSkladu.ID=tpz.IDZboSklad)
--doplnit fajfku, kde je shodná původní zakázka s nějakou nabídkou k dané zakázce
UPDATE kn SET NabidkaPuv=1
FROM Tabx_RS_KontrolaNabidekBudouciPohyby kn WITH(NOLOCK)
LEFT OUTER JOIN TabDokladyZbozi tdz WITH (NOLOCK) ON tdz.CisloZakazky=kn.CisloZakazky AND tdz.DruhPohybuZbo=11
LEFT OUTER JOIN TabPohybyZbozi tpz WITH (NOLOCK) ON tpz.IDDoklad=tdz.ID
WHERE tdz.CisloZakazky=kn.CisloZakazkyPuv AND kn.IDKmeneZbozi=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WITH(NOLOCK) WHERE TabStavSkladu.ID=tpz.IDZboSklad)


END;



GO

