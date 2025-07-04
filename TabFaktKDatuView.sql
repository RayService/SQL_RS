USE [RayService]
GO

/****** Object:  View [dbo].[TabFaktKDatuView]    Script Date: 04.07.2025 10:19:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFaktKDatuView] AS
SELECT
TabDokladyZbozi.Autor
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN CastkaZaoKc
 ELSE - CastkaZaoKc
 END AS CastkaZaoKc
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SNCelkemDokl
 ELSE - CastkaZaoVal
 END AS CastkaZaoVal
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN CastkaZaoValDoKc
 ELSE - CastkaZaoValDoKc
 END AS CastkaZaoValDoKc
,TabDokladyZbozi.CisloOrg
,TabDokladyZbozi.CisloZakazky
,TabDokladyZbozi.CisloZam
,TabDokladyZbozi.DatPovinnostiFa
,TabDokladyZbozi.DatPovinnostiFa_D
,TabDokladyZbozi.DatPovinnostiFa_M
,TabDokladyZbozi.DatPovinnostiFa_Y
,TabDokladyZbozi.DatPovinnostiFa_Q
,TabDokladyZbozi.DatPovinnostiFa_W
,TabDokladyZbozi.DatPovinnostiFa_X
,TabDokladyZbozi.DatPorizeni
,TabDokladyZbozi.DatPorizeni_D
,TabDokladyZbozi.DatPorizeni_M
,TabDokladyZbozi.DatPorizeni_Y
,TabDokladyZbozi.DatPorizeni_Q
,TabDokladyZbozi.DatPorizeni_W
,TabDokladyZbozi.DatPorizeni_X
,TabDokladyZbozi.DatPorizeniSkut
,TabDokladyZbozi.DatPorizeniSkut_D
,TabDokladyZbozi.DatPorizeniSkut_M
,TabDokladyZbozi.DatPorizeniSkut_Y
,TabDokladyZbozi.DatPorizeniSkut_Q
,TabDokladyZbozi.DatPorizeniSkut_W
,TabDokladyZbozi.DatPorizeniSkut_X
,TabDokladyZbozi.DatRealizace
,TabDokladyZbozi.DatRealizace_D
,TabDokladyZbozi.DatRealizace_M
,TabDokladyZbozi.DatRealizace_Y
,TabDokladyZbozi.DatRealizace_Q
,TabDokladyZbozi.DatRealizace_W
,TabDokladyZbozi.DatRealizace_X
,TabDokladyZbozi.DatUctovani
,TabDokladyZbozi.DatUctovani_D
,TabDokladyZbozi.DatUctovani_M
,TabDokladyZbozi.DatUctovani_Y
,TabDokladyZbozi.DatUctovani_Q
,TabDokladyZbozi.DatUctovani_W
,TabDokladyZbozi.DatUctovani_X
,TabDokladyZbozi.AutorUctovani
,TabDokladyZbozi.DatUhrady
,TabDokladyZbozi.DatUhrady_D
,TabDokladyZbozi.DatUhrady_M
,TabDokladyZbozi.DatUhrady_Y
,TabDokladyZbozi.DatUhrady_Q
,TabDokladyZbozi.DatUhrady_W
,TabDokladyZbozi.DatUhrady_X
,TabDokladyZbozi.DatZmeny
,TabDokladyZbozi.DatZmeny_D
,TabDokladyZbozi.DatZmeny_M
,TabDokladyZbozi.DatZmeny_Y
,TabDokladyZbozi.DatZmeny_Q
,TabDokladyZbozi.DatZmeny_W
,TabDokladyZbozi.DatZmeny_X
,TabDokladyZbozi.DodFak
,TabDokladyZbozi.DIC
,TabDokladyZbozi.DruhPohybuZbo
,TabDokladyZbozi.DruhPohybuPrevod
,TabDokladyZbozi.DUZP
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN EcCelkemDokl
 ELSE - EcCelkemDokl
 END AS EcCelkemDokl
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN EcCelkemDoklUcto
 ELSE - EcCelkemDoklUcto
 END AS EcCelkemDoklUcto
,TabDokladyZbozi.FormaUhrady
,TabDokladyZbozi.FormaDopravy
,TabDokladyZbozi.ID
,TabDokladyZbozi.IdBankSpoj
,TabDokladyZbozi.IdObdobiStavu
,TabDokladyZbozi.IdPosta
,TabDokladyZbozi.IDVozidlo
,TabDokladyZbozi.IDSklad
,TabDokladyZbozi.IdSkladPrevodu
,TabDokladyZbozi.JednotkaMeny
,TabDokladyZbozi.KontaktOsoba
,TabDokladyZbozi.KonstSymbol
,TabDokladyZbozi.KontaktZam
,TabDokladyZbozi.Kurz
,TabDokladyZbozi.KurzEuro
,TabDokladyZbozi.Mena
,TabDokladyZbozi.MistoUrceni
,TabDokladyZbozi.NavaznyDobropis
,TabDokladyZbozi.NavaznyDoklad
,TabDokladyZbozi.NOkruhCislo
,TabDokladyZbozi.Obdobi
,TabDokladyZbozi.PoradoveCislo
,TabDokladyZbozi.Poznamka
,TabDokladyZbozi.Prijemce
,TabDokladyZbozi.RadaDokladu
,TabDokladyZbozi.Realizovano
,TabDokladyZbozi.ZbyvaUvolnitValProSaldo
,TabDokladyZbozi.ZbyvaUvolnitKCProSaldo
,CONVERT(INT
 ,CASE WHEN DruhPohybuZbo IN (13,14)
 THEN 0
 ELSE 1
 END) AS Smer
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SNCelkemDokl
 ELSE - SNCelkemDokl
 END AS SNCelkemDokl
,TabDokladyZbozi.Splatnost
,TabDokladyZbozi.StredNaklad
,TabDokladyZbozi.StredVynos
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaKc
 ELSE - SumaKc
 END AS SumaKc
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaKcBezDPH
 ELSE - SumaKcBezDPH
 END AS SumaKcBezDPH
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaKcPoZao
 ELSE - SumaKcPoZao
 END AS SumaKcPoZao
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaKcPoZaoBezZal
 ELSE - SumaKcPoZaoBezZal
 END AS SumaKcPoZaoBezZal
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaKcPoZaoBezZalVal
 ELSE - SumaKcPoZaoBezZalVal
 END AS SumaKcPoZaoBezZalVal
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaUhrad
 ELSE - SumaUhrad
 END AS SumaUhrad
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaVal
 ELSE - SumaVal
 END AS SumaVal
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaValBezDPH
 ELSE - SumaValBezDPH
 END AS SumaValBezDPH
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaValPoZao
 ELSE - SumaValPoZao
 END AS SumaValPoZao
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN SumaVystavenychPlataku
 ELSE - SumaVystavenychPlataku
 END AS SumaVystavenychPlataku
,TabDokladyZbozi.TiskovyForm
,TabDokladyZbozi.TypPrevodky
,TabDokladyZbozi.Uctovano
,TabDokladyZbozi.UKod
,TabDokladyZbozi.VstupniCena
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN ZadanaCastkaZaoKc
 ELSE - ZadanaCastkaZaoKc
 END AS ZadanaCastkaZaoKc
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN ZadanaCastkaZaoVal
 ELSE - ZadanaCastkaZaoVal
 END AS ZadanaCastkaZaoVal
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN Zaloha
 ELSE - Zaloha
 END AS Zaloha
,CASE WHEN DruhPohybuZbo IN (13,19)
 THEN ZalohaVal
 ELSE - ZalohaVal
 END AS ZalohaVal
,TabDokladyZbozi.ZaokrouhleniFak
,TabDokladyZbozi.ZaokrouhleniFakVal
,TabDokladyZbozi.ZaokrNaPadesat
,TabDokladyZbozi.Zmenil
FROM TabDokladyZbozi
WHERE TabDokladyZbozi.DruhPohybuZbo IN (13,14,18,19)
AND TabDokladyZbozi.PoradoveCislo > 0
GO

