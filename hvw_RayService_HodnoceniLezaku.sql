USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayService_HodnoceniLezaku]    Script Date: 04.07.2025 7:20:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayService_HodnoceniLezaku] AS SELECT SS.ID,  S.Cislo, S.CisloStr, (KZ.ID) as IdKmen, KZ.SkupZbo, KZ.RegCis, KZ.Nazev1, SS.StavSkladu, SS.Mnozstvi,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530'),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'),0)) as MNprij,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'),0)) as MNvydej,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2002),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2002),0)) as MNprij2002,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2002),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2002),0)) as MNvydej2002,

(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2003),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2003),0)) as MNprij2003,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2003),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2003),0)) as MNvydej2003,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2004),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2004),0)) as MNprij2004,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2004),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2004),0)) as MNvydej2004,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2005),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2005),0)) as MNprij2005,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2005),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2005),0)) as MNvydej2005,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2006),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2006),0)) as MNprij2006,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2006),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2006),0)) as MNvydej2006,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2007),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2007),0)) as MNprij2007,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2007),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2007),0)) as MNvydej2007,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2008),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2008),0)) as MNprij2008,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2008),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2008),0)) as MNvydej2008,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2009),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2009),0)) as MNprij2009,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2009),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2009),0)) as MNvydej2009,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2010),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2010),0)) as MNprij2010,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2010),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2010),0)) as MNvydej2010,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2011),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2011),0)) as MNprij2011,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2011),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2011),0)) as MNvydej2011,

(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2012),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2012),0)) as MNprij2012,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2012),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2012),0)) as MNvydej2012, 


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2013),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2013),0)) as MNprij2013,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2013),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2013),0)) as MNvydej2013,


(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (0) AND DZ.RadaDokladu <>N'530' AND DZ.
DatPorizeni_Y=2014),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (1) AND DZ.RadaDokladu <>N'530'  AND DZ.
DatPorizeni_Y=2014),0)) as MNprij2014,
(ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2014),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2014),0)) as MNvydej2014,  

(CASE 
WHEN (SELECT year(getdate()))= 2011 AND Mnozstvi <>0 THEN (((ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2011),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2011),0))/Mnozstvi)*100) 
WHEN (SELECT year(getdate())) =2012 AND Mnozstvi <>0 THEN (((ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2012),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2012),0))/Mnozstvi)*100) 
WHEN (SELECT year(getdate())) =2013 AND Mnozstvi <>0 THEN (((ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2013),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2013),0))/Mnozstvi)*100) 
WHEN (SELECT year(getdate())) =2014 AND Mnozstvi <>0 THEN (((ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (2,4) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2014),0) -
ISNULL((SELECT SUM(PZ.Mnozstvi) FROM TabPohybyZbozi PZ LEFT JOIN TabDokladyZbozi DZ  ON DZ.ID = PZ. IDDoklad WHERE PZ.IdZboSklad =SS.ID AND DZ.Realizovano = 1 AND DZ.DruhPohybuZbo IN (3) AND DZ.RadaDokladu <>N'622'  AND DZ.
DatPorizeni_Y=2014),0))/Mnozstvi)*100) 
WHEN  Mnozstvi =0 THEN 0
END) as Podil

FROM TabStavSkladu SS
LEFT JOIN TabKmenZbozi KZ ON KZ.Id = SS.IDKmenZbozi
LEFT JOIN TabStrom S ON SS.Idsklad = S.Cislo
GO

