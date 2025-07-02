USE [HCvicna]
GO

/****** Object:  Table [dbo].[TabDokladyZbozi]    Script Date: 02.07.2025 13:30:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TabDokladyZbozi](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DruhPohybuZbo] [tinyint] NOT NULL,
	[DruhPohybuPrevod] [tinyint] NULL,
	[IDSklad] [nvarchar](30) NULL,
	[RadaDokladu] [nvarchar](3) NOT NULL,
	[PoradoveCislo] [int] NOT NULL,
	[StredNaklad] [nvarchar](30) NULL,
	[StredVynos] [nvarchar](30) NULL,
	[IdSkladPrevodu] [nvarchar](30) NULL,
	[TypPrevodky] [nvarchar](3) NULL,
	[CisloOrg] [int] NULL,
	[Prijemce] [int] NULL,
	[MistoUrceni] [int] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[DatPovinnostiFa] [datetime] NULL,
	[DatRealizace] [datetime] NULL,
	[DatUctovani] [datetime] NULL,
	[DUZP] [datetime] NULL,
	[Splatnost] [datetime] NULL,
	[Obdobi] [int] NOT NULL,
	[UKod] [int] NULL,
	[SazbaDPH] [numeric](5, 2) NULL,
	[SazbaSD] [numeric](19, 6) NOT NULL,
	[FormaUhrady] [nvarchar](30) NULL,
	[FormaDopravy] [nvarchar](30) NULL,
	[KonstSymbol] [nvarchar](10) NULL,
	[Poznamka] [nvarchar](max) NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[NOkruhCislo] [nvarchar](15) NULL,
	[CisloZakazky] [nvarchar](15) NULL,
	[Mena] [nvarchar](3) NULL,
	[Kurz] [numeric](19, 6) NOT NULL,
	[JednotkaMeny] [int] NOT NULL,
	[KurzEuro] [numeric](19, 6) NOT NULL,
	[VstupniCena] [tinyint] NOT NULL,
	[Sleva] [numeric](19, 6) NOT NULL,
	[Stav] [tinyint] NULL,
	[Nazev] [nvarchar](50) NULL,
	[Code] [nvarchar](20) NULL,
	[DoprDispo] [nvarchar](20) NULL,
	[PopisDodavky] [nvarchar](40) NULL,
	[TerminDodavky] [nvarchar](20) NULL,
	[Puvod] [nvarchar](20) NULL,
	[CisReferatu] [nvarchar](20) NULL,
	[Referat] [nvarchar](20) NULL,
	[Text1] [nvarchar](max) NULL,
	[Text2] [nvarchar](max) NULL,
	[Text3] [nvarchar](max) NULL,
	[SumaKc] [numeric](19, 6) NULL,
	[Zaloha] [numeric](19, 6) NOT NULL,
	[ZaokrouhleniFak] [smallint] NOT NULL,
	[ZaokrouhleniFakVal] [smallint] NOT NULL,
	[PomCislo] [nvarchar](15) NOT NULL,
	[NavaznyDoklad] [int] NULL,
	[NavaznyDobropis] [int] NULL,
	[DatUhrady] [datetime] NULL,
	[SumaUhrad] [numeric](19, 6) NULL,
	[IDPrikaz] [int] NULL,
	[IDBankSpoj] [int] NULL,
	[IDStazka] [int] NULL,
	[IDVozidlo] [int] NULL,
	[CisloZam] [int] NULL,
	[EcCelkemDokl] [numeric](19, 6) NULL,
	[EcCelkemDoklUcto] [numeric](19, 6) NULL,
	[SNCelkemDokl] [numeric](19, 6) NULL,
	[DodFak] [nvarchar](20) NOT NULL,
	[NavaznaObjednavka] [nvarchar](30) NOT NULL,
	[Splneno] [bit] NOT NULL,
	[DatumMixu] [datetime] NULL,
	[IDPosta] [int] NULL,
	[NastaveniSlev] [smallint] NOT NULL,
	[SumaVal] [numeric](19, 6) NULL,
	[ZalohaVal] [numeric](19, 6) NOT NULL,
	[StavRezervace] [nchar](1) NOT NULL,
	[Modul] [tinyint] NOT NULL,
	[HlidanyDoklad] [nchar](1) NOT NULL,
	[TiskovyForm] [int] NULL,
	[StornoDoklad] [int] NULL,
	[ZadanaCastkaZaoKc] [numeric](19, 6) NOT NULL,
	[ZadanaCastkaZaoVal] [numeric](19, 6) NOT NULL,
	[SumaVystavenychPlataku] [numeric](19, 6) NULL,
	[StavPrevodu] [smallint] NULL,
	[IDJCD] [int] NULL,
	[KontaktZam] [int] NULL,
	[IdObdobiStavu] [int] NULL,
	[KontaktOsoba] [int] NULL,
	[Nabidka] [int] NULL,
	[NabidkaCenik] [int] NOT NULL,
	[Rezim] [nvarchar](4) NULL,
	[CSCD] [bit] NOT NULL,
	[PoziceZaokrDPH] [tinyint] NOT NULL,
	[HraniceZaokrDPH] [tinyint] NOT NULL,
	[ZaokrDPHvaluty] [tinyint] NOT NULL,
	[IDstin] [int] NULL,
	[DIC] [nvarchar](15) NULL,
	[ZaokrDPHMalaCisla] [tinyint] NOT NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni],0),0),0)),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny],0),0),0)),
	[DatPovinnostiFa_D]  AS (datepart(day,[DatPovinnostiFa])),
	[DatPovinnostiFa_M]  AS (datepart(month,[DatPovinnostiFa])),
	[DatPovinnostiFa_Y]  AS (datepart(year,[DatPovinnostiFa])),
	[DatPovinnostiFa_Q]  AS (datepart(quarter,[DatPovinnostiFa])),
	[DatPovinnostiFa_W]  AS (datepart(week,[DatPovinnostiFa])),
	[DatPovinnostiFa_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPovinnostiFa],0),0),0)),
	[DatRealizace_D]  AS (datepart(day,[DatRealizace])),
	[DatRealizace_M]  AS (datepart(month,[DatRealizace])),
	[DatRealizace_Y]  AS (datepart(year,[DatRealizace])),
	[DatRealizace_Q]  AS (datepart(quarter,[DatRealizace])),
	[DatRealizace_W]  AS (datepart(week,[DatRealizace])),
	[DatRealizace_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatRealizace],0),0),0)),
	[DatSplneni]  AS ([DatRealizace]),
	[Realizovano]  AS (CONVERT([bit],case when [DatRealizace] IS NULL then (0) else (1) end,0)),
	[DatUctovani_D]  AS (datepart(day,[DatUctovani])),
	[DatUctovani_M]  AS (datepart(month,[DatUctovani])),
	[DatUctovani_Y]  AS (datepart(year,[DatUctovani])),
	[DatUctovani_Q]  AS (datepart(quarter,[DatUctovani])),
	[DatUctovani_W]  AS (datepart(week,[DatUctovani])),
	[DatUctovani_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatUctovani],0),0),0)),
	[Uctovano]  AS (CONVERT([bit],case when [DatUctovani] IS NULL then (0) else (1) end,0)),
	[DUZP_D]  AS (datepart(day,[DUZP])),
	[DUZP_M]  AS (datepart(month,[DUZP])),
	[DUZP_Y]  AS (datepart(year,[DUZP])),
	[DUZP_Q]  AS (datepart(quarter,[DUZP])),
	[DUZP_W]  AS (datepart(week,[DUZP])),
	[DUZP_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DUZP],0),0),0)),
	[Splatnost_D]  AS (datepart(day,[Splatnost])),
	[Splatnost_M]  AS (datepart(month,[Splatnost])),
	[Splatnost_Y]  AS (datepart(year,[Splatnost])),
	[Splatnost_Q]  AS (datepart(quarter,[Splatnost])),
	[Splatnost_W]  AS (datepart(week,[Splatnost])),
	[Splatnost_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[Splatnost],0),0),0)),
	[PlatnostDo]  AS ([Splatnost]),
	[TerminDodavkyDat]  AS ([Splatnost]),
	[TerminDodavkyDat_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[Splatnost],0),0),0)),
	[DatUhrady_D]  AS (datepart(day,[DatUhrady])),
	[DatUhrady_M]  AS (datepart(month,[DatUhrady])),
	[DatUhrady_Y]  AS (datepart(year,[DatUhrady])),
	[DatUhrady_Q]  AS (datepart(quarter,[DatUhrady])),
	[DatUhrady_W]  AS (datepart(week,[DatUhrady])),
	[DatUhrady_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatUhrady],0),0),0)),
	[EcSNCelkemDokl]  AS (CONVERT([numeric](19,6),[EcCelkemDokl]+[SNCelkemDokl],0)),
	[SumaKcBezDPH] [numeric](19, 6) NOT NULL,
	[SumaValBezDPH] [numeric](19, 6) NOT NULL,
	[RealizacniFak] [bit] NULL,
	[DatumDoruceni] [datetime] NULL,
	[DatumDoruceni_D]  AS (datepart(day,[DatumDoruceni])),
	[DatumDoruceni_M]  AS (datepart(month,[DatumDoruceni])),
	[DatumDoruceni_Y]  AS (datepart(year,[DatumDoruceni])),
	[DatumDoruceni_Q]  AS (datepart(quarter,[DatumDoruceni])),
	[DatumDoruceni_W]  AS (datepart(week,[DatumDoruceni])),
	[DatumDoruceni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumDoruceni],0),0),0)),
	[Organizace2] [int] NULL,
	[DatPorizeniSkut] [datetime] NOT NULL,
	[CastkaZaoValDoKc] [numeric](19, 6) NULL,
	[SamoVyZdrojKurzu] [int] NOT NULL,
	[SamoVyMenaDPH] [nvarchar](3) NULL,
	[SamoVyMenaDPHHM] [nvarchar](3) NULL,
	[SamoVyKurzDPH] [numeric](19, 6) NOT NULL,
	[SamoVyMnoKurzDPH] [int] NOT NULL,
	[SamoVyKurzDPHHM] [numeric](19, 6) NOT NULL,
	[SamoVyMnoKurzDPHHM] [int] NOT NULL,
	[SamoVyDICDPH] [nvarchar](15) NULL,
	[SamoVyDatumKurzuDPH] [datetime] NULL,
	[SamoVyDatumKurzuDPHHM] [datetime] NULL,
	[DatPorizeniSkut_D]  AS (datepart(day,[DatPorizeniSkut])),
	[DatPorizeniSkut_M]  AS (datepart(month,[DatPorizeniSkut])),
	[DatPorizeniSkut_Y]  AS (datepart(year,[DatPorizeniSkut])),
	[DatPorizeniSkut_Q]  AS (datepart(quarter,[DatPorizeniSkut])),
	[DatPorizeniSkut_W]  AS (datepart(week,[DatPorizeniSkut])),
	[DatPorizeniSkut_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeniSkut],0),0),0)),
	[SamoVyDatumKurzuDPH_D]  AS (datepart(day,[SamoVyDatumKurzuDPH])),
	[SamoVyDatumKurzuDPH_M]  AS (datepart(month,[SamoVyDatumKurzuDPH])),
	[SamoVyDatumKurzuDPH_Y]  AS (datepart(year,[SamoVyDatumKurzuDPH])),
	[SamoVyDatumKurzuDPH_Q]  AS (datepart(quarter,[SamoVyDatumKurzuDPH])),
	[SamoVyDatumKurzuDPH_W]  AS (datepart(week,[SamoVyDatumKurzuDPH])),
	[SamoVyDatumKurzuDPH_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[SamoVyDatumKurzuDPH],0),0),0)),
	[SamoVyDatumKurzuDPHHM_D]  AS (datepart(day,[SamoVyDatumKurzuDPHHM])),
	[SamoVyDatumKurzuDPHHM_M]  AS (datepart(month,[SamoVyDatumKurzuDPHHM])),
	[SamoVyDatumKurzuDPHHM_Y]  AS (datepart(year,[SamoVyDatumKurzuDPHHM])),
	[SamoVyDatumKurzuDPHHM_Q]  AS (datepart(quarter,[SamoVyDatumKurzuDPHHM])),
	[SamoVyDatumKurzuDPHHM_W]  AS (datepart(week,[SamoVyDatumKurzuDPHHM])),
	[SamoVyDatumKurzuDPHHM_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[SamoVyDatumKurzuDPHHM],0),0),0)),
	[DatumSplatnoRPT] [datetime] NULL,
	[DatumSplatnoRPT_D]  AS (datepart(day,[DatumSplatnoRPT])),
	[DatumSplatnoRPT_M]  AS (datepart(month,[DatumSplatnoRPT])),
	[DatumSplatnoRPT_Y]  AS (datepart(year,[DatumSplatnoRPT])),
	[DatumSplatnoRPT_Q]  AS (datepart(quarter,[DatumSplatnoRPT])),
	[DatumSplatnoRPT_W]  AS (datepart(week,[DatumSplatnoRPT])),
	[DatumSplatnoRPT_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumSplatnoRPT],0),0),0)),
	[DatumKurzu] [datetime] NULL,
	[DatumKurzu_D]  AS (datepart(day,[DatumKurzu])),
	[DatumKurzu_M]  AS (datepart(month,[DatumKurzu])),
	[DatumKurzu_Y]  AS (datepart(year,[DatumKurzu])),
	[DatumKurzu_Q]  AS (datepart(quarter,[DatumKurzu])),
	[DatumKurzu_W]  AS (datepart(week,[DatumKurzu])),
	[DatumKurzu_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumKurzu],0),0),0)),
	[SplatnoPocitatOd] [tinyint] NOT NULL,
	[SpecifickySymbol] [nvarchar](10) NOT NULL,
	[JeToZaloha] [bit] NOT NULL,
	[DodFakKV] [nvarchar](60) NOT NULL,
	[OpravnyDoklad] [bit] NOT NULL,
	[ZdrojCisKV] [tinyint] NOT NULL,
	[DruhSazbyDPH] [tinyint] NULL,
	[ZemeDPH] [nvarchar](3) NOT NULL,
	[ZalohaDanKurz] [numeric](19, 6) NOT NULL,
	[OpravDanDoklad] [bit] NOT NULL,
	[RezimMOSS] [tinyint] NOT NULL,
	[TerminDodavkyDat_D]  AS (datepart(day,[Splatnost])),
	[TerminDodavkyDat_M]  AS (datepart(month,[Splatnost])),
	[TerminDodavkyDat_Y]  AS (datepart(year,[Splatnost])),
	[TerminDodavkyDat_Q]  AS (datepart(quarter,[Splatnost])),
	[TerminDodavkyDat_W]  AS (datepart(week,[Splatnost])),
	[IDDanovyRezim] [int] NULL,
	[PlneniDoLimitu] [bit] NOT NULL,
	[KHDPHDoLimitu] [tinyint] NOT NULL,
	[RezimPreuctovaniSK] [bit] NOT NULL,
	[NastavPreuctovaniSK] [tinyint] NOT NULL,
	[ZbyvaUvolnitValProSaldo] [numeric](19, 6) NOT NULL,
	[ZbyvaUvolnitKCProSaldo] [numeric](19, 6) NOT NULL,
	[StavEET] [tinyint] NOT NULL,
	[DruhCU] [tinyint] NOT NULL,
	[PZ2] [nvarchar](20) NOT NULL,
	[FakturacniZam] [int] NULL,
	[StavNahPlneni] [tinyint] NOT NULL,
	[CastkaNahPlneni] [numeric](19, 6) NOT NULL,
	[DruhPohybuZboPZO]  AS (CONVERT([tinyint],case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) then (1) when [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) then (2)  end)),
	[PotvrDoruceni] [bit] NOT NULL,
	[JeNovaVetaEditor] [bit] NOT NULL,
	[SrazkovaDanVHM] [numeric](19, 6) NOT NULL,
	[JeToDDPP] [bit] NOT NULL,
	[PomerKoef] [numeric](19, 6) NULL,
	[NeupozNaNenavDok] [bit] NOT NULL,
	[StavZalFak] [tinyint] NULL,
	[ZpusobKurzZal] [tinyint] NULL,
	[Nehradit] [tinyint] NOT NULL,
	[ZboziSluzba] [tinyint] NOT NULL,
	[PoradoveCisloPuvodniFaKV] [nvarchar](32) NULL,
	[DelkaPorCis] [tinyint] NULL,
	[ParovaciZnak]  AS (CONVERT([nvarchar](20),([RadaDokladu]+isnull(replicate(N'0',case when [DelkaPorCis] IS NULL then (6) else [DelkaPorCis] end-len([PoradoveCislo])),N''))+CONVERT([nvarchar](11),[PoradoveCislo]))),
	[UctovanoNulovy] [bit] NOT NULL,
	[IdOSSOpr] [int] NULL,
	[PorCisKV]  AS (CONVERT([nvarchar](60),case when [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(13) then case [ZdrojCisKV] when (0) then CONVERT([nvarchar](20),([RadaDokladu]+isnull(replicate(N'0',case when [DelkaPorCis] IS NULL then (6) else [DelkaPorCis] end-len([PoradoveCislo])),N''))+CONVERT([nvarchar](11),[PoradoveCislo])) when (2) then case when [DodFakKV]<>'' then [DodFakKV] else [DodFak] end else [DodFak] end else case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then case when [DodFakKV]<>'' then [DodFakKV] else [DodFak] end  end end,(0))),
	[IDBankSpPrep] [int] NULL,
	[KonstSymbolPrep] [nvarchar](10) NULL,
	[SpecSymbolPrep] [nvarchar](10) NOT NULL,
	[SlevyBezRecykl] [bit] NOT NULL,
	[MetodaSD] [bit] NOT NULL,
	[VypoctenaLhutaSplatnosti]  AS (case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(13) then case [SplatnoPocitatOd] when (0) then datediff(day,[DatPorizeni],[Splatnost]) when (10) then datediff(day,getdate(),[Splatnost]) when (1) then datediff(day,[DatPorizeni],[Splatnost]) when (2) then datediff(day,[DUZP],[Splatnost]) when (3) then datediff(day,[DatPovinnostiFa],[Splatnost]) when (8) then datediff(day,[DatumDoruceni],[Splatnost]) when (4) then datediff(day,dateadd(month,(1),[DatPorizeni])-datepart(day,dateadd(month,(1),[DatPorizeni])),[Splatnost]) when (5) then datediff(day,dateadd(month,(1),[DUZP])-datepart(day,dateadd(month,(1),[DUZP])),[Splatnost]) when (6) then datediff(day,dateadd(month,(1),[DatPovinnostiFa])-datepart(day,dateadd(month,(1),[DatPovinnostiFa])),[Splatnost])  end  end),
	[DatRealMnoz] [datetime] NULL,
	[ZaokrNaPadesat] [smallint] NOT NULL,
	[CastkaZaoVal]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end-[SumaVal])),
	[SumaKcPoZaoBezZalVal]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end+[ZalohaVal])),
	[Saldo]  AS (CONVERT([numeric](19,6),case when [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(19) then  -(case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then ([SumaVal]-[ZbyvaUvolnitValProSaldo])+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])=(0.00) then (0.00) else case when abs([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0.05) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal]-[ZbyvaUvolnitValProSaldo],(2)),(1))/(2) end end else round(([SumaVal]-[ZbyvaUvolnitValProSaldo])+(0.000001),[ZaokrouhleniFakVal]) end end-[SumaUhrad]) else case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then ([SumaVal]-[ZbyvaUvolnitValProSaldo])+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])=(0.00) then (0.00) else case when abs([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0.05) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal]-[ZbyvaUvolnitValProSaldo],(2)),(1))/(2) end end else round(([SumaVal]-[ZbyvaUvolnitValProSaldo])+(0.000001),[ZaokrouhleniFakVal]) end end-[SumaUhrad] end)),
	[SumaValPoZao]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end)),
	[DnuProdleniZapl]  AS (case when (case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then ([SumaVal]-[ZbyvaUvolnitValProSaldo])+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])=(0.00) then (0.00) else case when abs([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0.05) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal]-[ZbyvaUvolnitValProSaldo],(2)),(1))/(2) end end else round(([SumaVal]-[ZbyvaUvolnitValProSaldo])+(0.000001),[ZaokrouhleniFakVal]) end end-[SumaUhrad])<(0.0009) then datediff(day,[Splatnost],case when abs([SumaVal])<(0.0009) then [Splatnost] else [DatUhrady] end)  end),
	[DnuProdleniNazapl]  AS (case when (case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then ([SumaVal]-[ZbyvaUvolnitValProSaldo])+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])=(0.00) then (0.00) else case when abs([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0.05) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal]-[ZbyvaUvolnitValProSaldo],(2)),(1))/(2) end end else round(([SumaVal]-[ZbyvaUvolnitValProSaldo])+(0.000001),[ZaokrouhleniFakVal]) end end-[SumaUhrad])>(0.0009) then case when datediff(day,[Splatnost],getdate())<(0) then datediff(day,[Splatnost],getdate()) else datediff(day,[Splatnost],getdate()) end  end),
	[DnuProdleni]  AS (case when (case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then ([SumaVal]-[ZbyvaUvolnitValProSaldo])+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])=(0.00) then (0.00) else case when abs([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0.05) then case when ([SumaVal]-[ZbyvaUvolnitValProSaldo])<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal]-[ZbyvaUvolnitValProSaldo],(2)),(1))/(2) end end else round(([SumaVal]-[ZbyvaUvolnitValProSaldo])+(0.000001),[ZaokrouhleniFakVal]) end end-[SumaUhrad])>(0.0009) then datediff(day,[Splatnost],getdate()) else datediff(day,[Splatnost],case when abs([SumaVal])<(0.0009) then [Splatnost] else [DatUhrady] end) end),
	[RealizovanoMnoz]  AS (CONVERT([bit],case when [DatRealMnoz] IS NULL then (0) else (1) end)),
	[DatRealMnoz_D]  AS (datepart(day,[DatRealMnoz])),
	[DatRealMnoz_M]  AS (datepart(month,[DatRealMnoz])),
	[DatRealMnoz_Y]  AS (datepart(year,[DatRealMnoz])),
	[DatRealMnoz_Q]  AS (datepart(quarter,[DatRealMnoz])),
	[DatRealMnoz_W]  AS (datepart(week,[DatRealMnoz])),
	[DatRealMnoz_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatRealMnoz])))),
	[SumaKcPoZao]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaKc]+[ZadanaCastkaZaoKc] else case when [CastkaZaoValDoKc] IS NOT NULL AND [Kurz]<>(1.00) then [SumaKc]+[CastkaZaoValDoKc] else case when [ZaokrNaPadesat]=(6) then case when [SumaKc]=(0.00) then (0.00) else case when abs([SumaKc])<(0.05) then case when [SumaKc]<(0) then (-0.05) else (0.05) end else CONVERT([numeric](19,6),round((2)*round([SumaKc],(2)),(1))/(2)) end end else case when [ZaokrNaPadesat]=(7) then round([Kurz]*case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end,(2)) else round([SumaKc]+(0.000001),[ZaokrouhleniFak]) end end end end)),
	[CastkaZaoKc]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaKc]+[ZadanaCastkaZaoKc] else case when [CastkaZaoValDoKc] IS NOT NULL AND [Kurz]<>(1.00) then [SumaKc]+[CastkaZaoValDoKc] else case when [ZaokrNaPadesat]=(6) then case when [SumaKc]=(0.00) then (0.00) else case when abs([SumaKc])<(0.05) then case when [SumaKc]<(0) then (-0.05) else (0.05) end else CONVERT([numeric](19,6),round((2)*round([SumaKc],(2)),(1))/(2)) end end else case when [ZaokrNaPadesat]=(7) then round([Kurz]*case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end,(2)) else round([SumaKc]+(0.000001),[ZaokrouhleniFak]) end end end end-[SumaKc])),
	[SumaKcPoZaoBezZal]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaKc]+[ZadanaCastkaZaoKc] else case when [CastkaZaoValDoKc] IS NOT NULL AND [Kurz]<>(1.00) then [SumaKc]+[CastkaZaoValDoKc] else case when [ZaokrNaPadesat]=(6) then case when [SumaKc]=(0.00) then (0.00) else case when abs([SumaKc])<(0.05) then case when [SumaKc]<(0) then (-0.05) else (0.05) end else CONVERT([numeric](19,6),round((2)*round([SumaKc],(2)),(1))/(2)) end end else case when [ZaokrNaPadesat]=(7) then round([Kurz]*case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end,(2)) else round([SumaKc]+(0.000001),[ZaokrouhleniFak]) end end end end+[Zaloha])),
	[PrevodRealizovat] [bit] NOT NULL,
	[OsvobozenaPlneni] [tinyint] NOT NULL,
	[PrevodRealizovatMno] [bit] NOT NULL,
	[DSNCelkemDokl] [numeric](19, 6) NULL,
	[AutorRealMno] [nvarchar](128) NOT NULL,
	[AutorRealFin] [nvarchar](128) NOT NULL,
	[StavFakturace] [nchar](1) NOT NULL,
	[Neupominat] [bit] NOT NULL,
	[Nepenalizovat] [bit] NOT NULL,
	[SystemRowVersion] [timestamp] NOT NULL,
	[SystemRowVersionText]  AS (CONVERT([nvarchar](16),CONVERT([binary](8),[SystemRowVersion]),(2))),
	[Kurz_KorZal] [numeric](19, 6) NOT NULL,
	[MetodaDSN] [tinyint] NOT NULL,
	[AVAReferenceID] [nvarchar](40) NOT NULL,
	[AVAExternalID] [nvarchar](255) NOT NULL,
	[AVAOutputFlag] [tinyint] NOT NULL,
	[AVASentDate] [datetime] NULL,
	[AVASentDate_D]  AS (datepart(day,[AVASentDate])),
	[AVASentDate_M]  AS (datepart(month,[AVASentDate])),
	[AVASentDate_Y]  AS (datepart(year,[AVASentDate])),
	[AVASentDate_Q]  AS (datepart(quarter,[AVASentDate])),
	[AVASentDate_W]  AS (datepart(week,[AVASentDate])),
	[AVASentDate_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[AVASentDate])))),
	[LimitObratu] [bit] NOT NULL,
	[ExterniCisloOrParovaciZnakDObj] [nvarchar](30) NOT NULL,
	[Cislo]  AS (CONVERT([nvarchar](17),(case when [PoradoveCislo]<(0) then N'-' else N'' end+isnull(replicate(N'0',case when [DelkaPorCis] IS NULL then (6) else [DelkaPorCis] end-len(abs([PoradoveCislo]))),N''))+CONVERT([nvarchar](17),abs([PoradoveCislo])))),
	[AutorUctovani] [nvarchar](128) NOT NULL,
	[SumaKcDPoh]  AS (case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(19) then  -[SumaKc] else [SumaKc] end),
	[KcZvyseni]  AS (case when [DruhPohybuZbo]=(6) OR [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(24) OR [DruhPohybuZbo]=(27) OR [DruhPohybuZbo]=(3) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(0) OR [DruhPohybuZbo]=(0) then CONVERT([numeric](19,6),[SumaKc])  end),
	[KcSnizeni]  AS (case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(25) OR [DruhPohybuZbo]=(26) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) then CONVERT([numeric](19,6),[SumaKc])  end),
	[KcZvSn]  AS (case when [DruhPohybuZbo]=(6) OR [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(24) OR [DruhPohybuZbo]=(27) OR [DruhPohybuZbo]=(3) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(0) OR [DruhPohybuZbo]=(0) then CONVERT([numeric](19,6),[SumaKc]) when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(25) OR [DruhPohybuZbo]=(26) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) then CONVERT([numeric](19,6), -[SumaKc])  end),
	[SNCelkemDoklDruh]  AS (case when [DruhPohybuZbo]=(6) OR [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(24) OR [DruhPohybuZbo]=(27) OR [DruhPohybuZbo]=(3) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(0) OR [DruhPohybuZbo]=(0) then CONVERT([numeric](19,6),[SNCelkemDokl]) when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(25) OR [DruhPohybuZbo]=(26) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) then CONVERT([numeric](19,6), -[SNCelkemDokl])  end),
	[EcSNCelkemDoklDruh]  AS (case when [DruhPohybuZbo]=(6) OR [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(24) OR [DruhPohybuZbo]=(27) OR [DruhPohybuZbo]=(3) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(0) OR [DruhPohybuZbo]=(0) then CONVERT([numeric](19,6),[EcCelkemDokl]+[SNCelkemDokl]) when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(25) OR [DruhPohybuZbo]=(26) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) then CONVERT([numeric](19,6), -([EcCelkemDokl]+[SNCelkemDokl]))  end),
	[EcZvyseni]  AS (case when [DruhPohybuZbo]=(6) OR [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(24) OR [DruhPohybuZbo]=(27) OR [DruhPohybuZbo]=(3) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(0) OR [DruhPohybuZbo]=(0) then CONVERT([numeric](19,6),[EcCelkemDokl])  end),
	[EcSnizeni]  AS (case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(25) OR [DruhPohybuZbo]=(26) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) then CONVERT([numeric](19,6),[EcCelkemDokl])  end),
	[EcZvSn]  AS (case when [DruhPohybuZbo]=(6) OR [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(24) OR [DruhPohybuZbo]=(27) OR [DruhPohybuZbo]=(3) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(0) OR [DruhPohybuZbo]=(0) then CONVERT([numeric](19,6),[EcCelkemDokl]) when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(25) OR [DruhPohybuZbo]=(26) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) then CONVERT([numeric](19,6), -[EcCelkemDokl])  end),
	[SumaKcBezDPHDruh]  AS (case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(19) then  -[SumaKcBezDPH] else [SumaKcBezDPH] end),
	[SumaValBezDPHDruh]  AS (case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(19) then  -[SumaValBezDPH] else [SumaValBezDPH] end),
	[KcBezDPHZvyseni]  AS (case when [DruhPohybuZbo]=(6) OR [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(24) OR [DruhPohybuZbo]=(27) OR [DruhPohybuZbo]=(3) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(0) OR [DruhPohybuZbo]=(0) then [SumaKcBezDPH]  end),
	[KcBezDPHSnizeni]  AS (case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(25) OR [DruhPohybuZbo]=(26) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) then [SumaKcBezDPH]  end),
	[KcBezDPHZvSn]  AS (case when [DruhPohybuZbo]=(6) OR [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(24) OR [DruhPohybuZbo]=(27) OR [DruhPohybuZbo]=(3) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(0) OR [DruhPohybuZbo]=(0) then [SumaKcBezDPH] when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(25) OR [DruhPohybuZbo]=(26) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) then  -[SumaKcBezDPH]  end),
	[SumaValDPoh]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(19) then  -[SumaVal] else [SumaVal] end)),
	[EcCelkemDoklUctoDruhovy]  AS (case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(19) then  -[EcCelkemDoklUcto] else [EcCelkemDoklUcto] end),
	[SumaValPoZaoDPoh]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(19) then  -case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end else case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end end)),
	[SumaKcPoZaoDPoh]  AS (CONVERT([numeric](20,6),case when [DruhPohybuZbo]=(1) OR [DruhPohybuZbo]=(2) OR [DruhPohybuZbo]=(4) OR [DruhPohybuZbo]=(9) OR [DruhPohybuZbo]=(10) OR [DruhPohybuZbo]=(11) AND [DruhCU]=(1) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(19) then  -case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaKc]+[ZadanaCastkaZaoKc] else case when [CastkaZaoValDoKc] IS NOT NULL AND [Kurz]<>(1.00) then [SumaKc]+[CastkaZaoValDoKc] else case when [ZaokrNaPadesat]=(6) then case when [SumaKc]=(0.00) then (0.00) else case when abs([SumaKc])<(0.05) then case when [SumaKc]<(0) then (-0.05) else (0.05) end else CONVERT([numeric](19,6),round((2)*round([SumaKc],(2)),(1))/(2)) end end else case when [ZaokrNaPadesat]=(7) then round([Kurz]*case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end,(2)) else round([SumaKc]+(0.000001),[ZaokrouhleniFak]) end end end end else case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaKc]+[ZadanaCastkaZaoKc] else case when [CastkaZaoValDoKc] IS NOT NULL AND [Kurz]<>(1.00) then [SumaKc]+[CastkaZaoValDoKc] else case when [ZaokrNaPadesat]=(6) then case when [SumaKc]=(0.00) then (0.00) else case when abs([SumaKc])<(0.05) then case when [SumaKc]<(0) then (-0.05) else (0.05) end else CONVERT([numeric](19,6),round((2)*round([SumaKc],(2)),(1))/(2)) end end else case when [ZaokrNaPadesat]=(7) then round([Kurz]*case when [DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) then [SumaVal]+[ZadanaCastkaZaoVal] else case when [ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) then case when [SumaVal]=(0.00) then (0.00) else case when abs([SumaVal])<(0.05) then case when [SumaVal]<(0) then (-0.05) else (0.05) end else round((2)*round([SumaVal],(2)),(1))/(2) end end else round([SumaVal]+(0.000001),[ZaokrouhleniFakVal]) end end,(2)) else round([SumaKc]+(0.000001),[ZaokrouhleniFak]) end end end end end)),
 CONSTRAINT [PK__TabDokladyZbozi__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__TabDokladyZbozi__AVAReferenceID] UNIQUE NONCLUSTERED 
(
	[AVAReferenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__TabDokladyZbozi__Obdobi__IDSklad__DruhPohybuZbo__RadaDokladu__PoradoveCislo] UNIQUE NONCLUSTERED 
(
	[Obdobi] ASC,
	[IDSklad] ASC,
	[DruhPohybuZbo] ASC,
	[RadaDokladu] ASC,
	[PoradoveCislo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SazbaSD]  DEFAULT ((0.0)) FOR [SazbaSD]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Kurz]  DEFAULT ((1.0)) FOR [Kurz]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__JednotkaMeny]  DEFAULT ((1)) FOR [JednotkaMeny]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__KurzEuro]  DEFAULT ((0)) FOR [KurzEuro]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__VstupniCena]  DEFAULT ((0)) FOR [VstupniCena]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Sleva]  DEFAULT ((0.0)) FOR [Sleva]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SumaKc]  DEFAULT ((0.0)) FOR [SumaKc]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Zaloha]  DEFAULT ((0.0)) FOR [Zaloha]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZaokrouhleniFak]  DEFAULT ((2)) FOR [ZaokrouhleniFak]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZaokrouhleniFakVal]  DEFAULT ((2)) FOR [ZaokrouhleniFakVal]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__PomCislo]  DEFAULT ('') FOR [PomCislo]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SumaUhrad]  DEFAULT ((0.0)) FOR [SumaUhrad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__EcCelkemDokl]  DEFAULT ((0.0)) FOR [EcCelkemDokl]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__EcCelkemDoklUcto]  DEFAULT ((0.0)) FOR [EcCelkemDoklUcto]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SNCelkemDokl]  DEFAULT ((0.0)) FOR [SNCelkemDokl]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__DodFak]  DEFAULT ('') FOR [DodFak]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__NavaznaObjednavka]  DEFAULT ('') FOR [NavaznaObjednavka]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Splneno]  DEFAULT ((0)) FOR [Splneno]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__NastaveniSlev]  DEFAULT ((0)) FOR [NastaveniSlev]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SumaVal]  DEFAULT ((0.0)) FOR [SumaVal]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZalohaVal]  DEFAULT ((0.0)) FOR [ZalohaVal]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__StavRezervace]  DEFAULT (N' ') FOR [StavRezervace]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Modul]  DEFAULT ((0)) FOR [Modul]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__HlidanyDoklad]  DEFAULT (N'N') FOR [HlidanyDoklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZadanaCastkaZaoKc]  DEFAULT ((0.0)) FOR [ZadanaCastkaZaoKc]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZadanaCastkaZaoVal]  DEFAULT ((0.0)) FOR [ZadanaCastkaZaoVal]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SumaVystavenychPlataku]  DEFAULT ((0.0)) FOR [SumaVystavenychPlataku]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__StavPrevodu]  DEFAULT ((0)) FOR [StavPrevodu]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__NabidkaCenik]  DEFAULT ((0)) FOR [NabidkaCenik]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__CSCD]  DEFAULT ((0)) FOR [CSCD]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__PoziceZaokrDPH]  DEFAULT ((2)) FOR [PoziceZaokrDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__HraniceZaokrDPH]  DEFAULT ((4)) FOR [HraniceZaokrDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZaokrDPHvaluty]  DEFAULT ((0)) FOR [ZaokrDPHvaluty]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZaokrDPHMalaCisla]  DEFAULT ((0)) FOR [ZaokrDPHMalaCisla]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SumaKcBezDPH]  DEFAULT ((0.0)) FOR [SumaKcBezDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SumaValBezDPH]  DEFAULT ((0.0)) FOR [SumaValBezDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__RealizacniFak]  DEFAULT ((0)) FOR [RealizacniFak]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__DatPorizeniSkut]  DEFAULT (getdate()) FOR [DatPorizeniSkut]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__CastkaZaoValDoKc]  DEFAULT ((0.0)) FOR [CastkaZaoValDoKc]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SamoVyZdrojKurzu]  DEFAULT ((2)) FOR [SamoVyZdrojKurzu]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SamoVyKurzDPH]  DEFAULT ((1)) FOR [SamoVyKurzDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SamoVyMnoKurzDPH]  DEFAULT ((1)) FOR [SamoVyMnoKurzDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SamoVyKurzDPHHM]  DEFAULT ((1)) FOR [SamoVyKurzDPHHM]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SamoVyMnoKurzDPHHM]  DEFAULT ((1)) FOR [SamoVyMnoKurzDPHHM]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SplatnoPocitatOd]  DEFAULT ((0)) FOR [SplatnoPocitatOd]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SpecifickySymbol]  DEFAULT ('') FOR [SpecifickySymbol]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__JeToZaloha]  DEFAULT ((0)) FOR [JeToZaloha]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__DodFakKV]  DEFAULT ('') FOR [DodFakKV]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__OpravnyDoklad]  DEFAULT ((0)) FOR [OpravnyDoklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZdrojCisKV]  DEFAULT ((0)) FOR [ZdrojCisKV]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZalohaDanKurz]  DEFAULT ((0.0)) FOR [ZalohaDanKurz]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__OpravDanDoklad]  DEFAULT ((0)) FOR [OpravDanDoklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__RezimMOSS]  DEFAULT ((0)) FOR [RezimMOSS]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__PlneniDoLimitu]  DEFAULT ((1)) FOR [PlneniDoLimitu]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__KHDPHDoLimitu]  DEFAULT ((1)) FOR [KHDPHDoLimitu]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__RezimPreuctovaniSK]  DEFAULT ((0)) FOR [RezimPreuctovaniSK]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__NastavPreuctovaniSK]  DEFAULT ((1)) FOR [NastavPreuctovaniSK]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZbyvaUvolnitValProSaldo]  DEFAULT ((0.0)) FOR [ZbyvaUvolnitValProSaldo]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZbyvaUvolnitKCProSaldo]  DEFAULT ((0.0)) FOR [ZbyvaUvolnitKCProSaldo]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__StavEET]  DEFAULT ((2)) FOR [StavEET]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__DruhCU]  DEFAULT ((1)) FOR [DruhCU]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__PZ2]  DEFAULT ('') FOR [PZ2]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__StavNahPlneni]  DEFAULT ((0)) FOR [StavNahPlneni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__CastkaNahPlneni]  DEFAULT ((0.0)) FOR [CastkaNahPlneni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__PotvrDoruceni]  DEFAULT ((0)) FOR [PotvrDoruceni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__JeNovaVetaEditor]  DEFAULT ((0)) FOR [JeNovaVetaEditor]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SrazkovaDanVHM]  DEFAULT ((0.0)) FOR [SrazkovaDanVHM]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__JeToDDPP]  DEFAULT ((0)) FOR [JeToDDPP]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__NeupozNaNenavDok]  DEFAULT ((0)) FOR [NeupozNaNenavDok]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Nehradit]  DEFAULT ((0)) FOR [Nehradit]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZboziSluzba]  DEFAULT ((0)) FOR [ZboziSluzba]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__UctovanoNulovy]  DEFAULT ((0)) FOR [UctovanoNulovy]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SpecSymbolPrep]  DEFAULT ('') FOR [SpecSymbolPrep]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__SlevyBezRecykl]  DEFAULT ((0)) FOR [SlevyBezRecykl]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__MetodaSD]  DEFAULT ((0)) FOR [MetodaSD]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ZaokrNaPadesat]  DEFAULT ((0)) FOR [ZaokrNaPadesat]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__PrevodRealizovat]  DEFAULT ((0)) FOR [PrevodRealizovat]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__OsvobozenaPlneni]  DEFAULT ((0)) FOR [OsvobozenaPlneni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__PrevodRealizovatMno]  DEFAULT ((0)) FOR [PrevodRealizovatMno]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__DSNCelkemDokl]  DEFAULT ((0.0)) FOR [DSNCelkemDokl]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__AutorRealMno]  DEFAULT ('') FOR [AutorRealMno]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__AutorRealFin]  DEFAULT ('') FOR [AutorRealFin]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__StavFakturace]  DEFAULT (N' ') FOR [StavFakturace]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Neupominat]  DEFAULT ((0)) FOR [Neupominat]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Nepenalizovat]  DEFAULT ((0)) FOR [Nepenalizovat]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__Kurz_KorZal]  DEFAULT ((1.0)) FOR [Kurz_KorZal]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__MetodaDSN]  DEFAULT ((0)) FOR [MetodaDSN]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__AVAReferenceID]  DEFAULT (CONVERT([nvarchar](36),CONVERT([uniqueidentifier],newid()))) FOR [AVAReferenceID]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__AVAExternalID]  DEFAULT ('') FOR [AVAExternalID]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__AVAOutputFlag]  DEFAULT ((0)) FOR [AVAOutputFlag]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__LimitObratu]  DEFAULT ((0)) FOR [LimitObratu]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__ExterniCisloOrParovaciZnakDObj]  DEFAULT ('') FOR [ExterniCisloOrParovaciZnakDObj]
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ADD  CONSTRAINT [DF__TabDokladyZbozi__AutorUctovani]  DEFAULT ('') FOR [AutorUctovani]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__CisloOrg] FOREIGN KEY([CisloOrg])
REFERENCES [dbo].[TabCisOrg] ([CisloOrg])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__CisloOrg]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__CisloOrg__DIC] FOREIGN KEY([CisloOrg], [DIC])
REFERENCES [dbo].[TabDICOrg] ([CisloOrg], [DIC])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__CisloOrg__DIC]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__CisloZakazky] FOREIGN KEY([CisloZakazky])
REFERENCES [dbo].[TabZakazka] ([CisloZakazky])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__CisloZakazky]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__CisloZam] FOREIGN KEY([CisloZam])
REFERENCES [dbo].[TabCisZam] ([Cislo])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__CisloZam]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__FakturacniZam] FOREIGN KEY([FakturacniZam])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__FakturacniZam]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__FormaDopravy] FOREIGN KEY([FormaDopravy])
REFERENCES [dbo].[TabFormaDopravy] ([FormaDopravy])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__FormaDopravy]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__FormaUhrady] FOREIGN KEY([FormaUhrady])
REFERENCES [dbo].[TabFormaUhrady] ([FormaUhrady])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__FormaUhrady]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDBankSpoj] FOREIGN KEY([IDBankSpoj])
REFERENCES [dbo].[TabBankSpojeni] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDBankSpoj]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDBankSpPrep] FOREIGN KEY([IDBankSpPrep])
REFERENCES [dbo].[TabBankSpojeni] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDBankSpPrep]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDDanovyRezim] FOREIGN KEY([IDDanovyRezim])
REFERENCES [dbo].[TabDanovyRezim] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDDanovyRezim]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDJCD] FOREIGN KEY([IDJCD])
REFERENCES [dbo].[TabJCD] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDJCD]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IdObdobiStavu] FOREIGN KEY([IdObdobiStavu])
REFERENCES [dbo].[TabObdobiStavu] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IdObdobiStavu]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IdOSSOpr] FOREIGN KEY([IdOSSOpr])
REFERENCES [dbo].[TabMOSS] ([Id])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IdOSSOpr]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDPosta] FOREIGN KEY([IDPosta])
REFERENCES [dbo].[TabPosta] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDPosta]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDPrikaz] FOREIGN KEY([IDPrikaz])
REFERENCES [dbo].[TabPrikaz] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDPrikaz]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDSklad] FOREIGN KEY([IDSklad])
REFERENCES [dbo].[TabStrom] ([Cislo])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDSklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IdSkladPrevodu] FOREIGN KEY([IdSkladPrevodu])
REFERENCES [dbo].[TabStrom] ([Cislo])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IdSkladPrevodu]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDStazka] FOREIGN KEY([IDStazka])
REFERENCES [dbo].[TabIStazka] ([id])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDStazka]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDstin] FOREIGN KEY([IDstin])
REFERENCES [dbo].[TabDokladyZbozi] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDstin]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__IDVozidlo] FOREIGN KEY([IDVozidlo])
REFERENCES [dbo].[TabIVozidlo] ([id])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__IDVozidlo]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__KontaktOsoba] FOREIGN KEY([KontaktOsoba])
REFERENCES [dbo].[TabCisKOs] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__KontaktOsoba]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__KontaktZam] FOREIGN KEY([KontaktZam])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__KontaktZam]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__Mena] FOREIGN KEY([Mena])
REFERENCES [dbo].[TabKodMen] ([Kod])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__Mena]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__MistoUrceni] FOREIGN KEY([MistoUrceni])
REFERENCES [dbo].[TabCisOrg] ([CisloOrg])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__MistoUrceni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__Nabidka] FOREIGN KEY([Nabidka])
REFERENCES [dbo].[TabDokladyZbozi] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__Nabidka]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__NavaznyDobropis] FOREIGN KEY([NavaznyDobropis])
REFERENCES [dbo].[TabDokladyZbozi] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__NavaznyDobropis]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__NavaznyDoklad] FOREIGN KEY([NavaznyDoklad])
REFERENCES [dbo].[TabDokladyZbozi] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__NavaznyDoklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__NOkruhCislo] FOREIGN KEY([NOkruhCislo])
REFERENCES [dbo].[TabNakladovyOkruh] ([Cislo])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__NOkruhCislo]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__Obdobi] FOREIGN KEY([Obdobi])
REFERENCES [dbo].[TabObdobi] ([Id])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__Obdobi]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__Organizace2] FOREIGN KEY([Organizace2])
REFERENCES [dbo].[TabCisOrg] ([CisloOrg])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__Organizace2]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__Prijemce] FOREIGN KEY([Prijemce])
REFERENCES [dbo].[TabCisOrg] ([CisloOrg])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__Prijemce]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__RadaDokladu__DruhPohybuZbo] FOREIGN KEY([RadaDokladu], [DruhPohybuZbo])
REFERENCES [dbo].[TabDruhDokZbo] ([RadaDokladu], [DruhPohybuZbo])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__RadaDokladu__DruhPohybuZbo]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__SamoVyMenaDPH] FOREIGN KEY([SamoVyMenaDPH])
REFERENCES [dbo].[TabKodMen] ([Kod])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__SamoVyMenaDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__SamoVyMenaDPHHM] FOREIGN KEY([SamoVyMenaDPHHM])
REFERENCES [dbo].[TabKodMen] ([Kod])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__SamoVyMenaDPHHM]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__SazbaDPH] FOREIGN KEY([SazbaDPH])
REFERENCES [dbo].[TabDPH] ([Sazba])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__SazbaDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__StornoDoklad] FOREIGN KEY([StornoDoklad])
REFERENCES [dbo].[TabDokladyZbozi] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__StornoDoklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__StredNaklad] FOREIGN KEY([StredNaklad])
REFERENCES [dbo].[TabStrom] ([Cislo])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__StredNaklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__StredVynos] FOREIGN KEY([StredVynos])
REFERENCES [dbo].[TabStrom] ([Cislo])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__StredVynos]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__TiskovyForm] FOREIGN KEY([TiskovyForm])
REFERENCES [dbo].[TabFormDef] ([ID])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__TiskovyForm]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__TypPrevodky__DruhPohybuPrevod] FOREIGN KEY([TypPrevodky], [DruhPohybuPrevod])
REFERENCES [dbo].[TabDruhDokZbo] ([RadaDokladu], [DruhPohybuZbo])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__TypPrevodky__DruhPohybuPrevod]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__UKod] FOREIGN KEY([UKod])
REFERENCES [dbo].[TabUKod] ([CisloKontace])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__UKod]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [FK__TabDokladyZbozi__ZemeDPH] FOREIGN KEY([ZemeDPH])
REFERENCES [dbo].[TabZeme] ([ISOKod])
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [FK__TabDokladyZbozi__ZemeDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__AVAOutputFlag] CHECK  (([AVAOutputFlag]=(5) OR [AVAOutputFlag]=(4) OR [AVAOutputFlag]=(3) OR [AVAOutputFlag]=(2) OR [AVAOutputFlag]=(1) OR [AVAOutputFlag]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__AVAOutputFlag]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__CastkaNahPlneni] CHECK  (([CastkaNahPlneni]=(0.0) OR ([DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(13)) AND [StavNahPlneni]<>(0) AND [StavNahPlneni]<>(5)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__CastkaNahPlneni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__DelkaPorCis] CHECK  (([DelkaPorCis]=(7) OR [DelkaPorCis]=(6)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__DelkaPorCis]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__DruhCU] CHECK  (([DruhCU]>=(0) AND [DruhCU]<=(1)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__DruhCU]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__DruhPohybuPrevod] CHECK  (([DruhPohybuPrevod]>=(0) AND [DruhPohybuPrevod]<=(66)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__DruhPohybuPrevod]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__DruhPohybuZbo] CHECK  (([DruhPohybuZbo]>=(0) AND [DruhPohybuZbo]<=(66)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__DruhPohybuZbo]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__DruhSazbyDPH] CHECK  (([DruhSazbyDPH]>=(0) AND [DruhSazbyDPH]<=(8)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__DruhSazbyDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__FakturacniZam] CHECK  (([FakturacniZam] IS NULL OR [CisloOrg] IS NULL))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__FakturacniZam]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__HlidanyDoklad] CHECK  ((ascii([HlidanyDoklad])=(65) OR ascii([HlidanyDoklad])=(78)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__HlidanyDoklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__HraniceZaokrDPH] CHECK  (([HraniceZaokrDPH]>=(0) AND [HraniceZaokrDPH]<=(5)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__HraniceZaokrDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__IDSklad] CHECK  ((case when [IDSklad] IS NULL then (0) else (1) end=case when [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(13) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(19) then (0) else (1) end))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__IDSklad]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__JednotkaMeny] CHECK  (([JednotkaMeny]>(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__JednotkaMeny]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__KHDPHDoLimitu] CHECK  (([KHDPHDoLimitu]=(2) OR [KHDPHDoLimitu]=(1) OR [KHDPHDoLimitu]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__KHDPHDoLimitu]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__Kurz] CHECK  (([Kurz]>(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__Kurz]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__Kurz_KorZal] CHECK  (([Kurz_KorZal]>(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__Kurz_KorZal]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__MetodaDSN] CHECK  (([MetodaDSN]=(1) OR [MetodaDSN]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__MetodaDSN]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__NastavPreuctovaniSK] CHECK  (([NastavPreuctovaniSK]=(2) OR [NastavPreuctovaniSK]=(1) OR [NastavPreuctovaniSK]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__NastavPreuctovaniSK]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__Nehradit] CHECK  (([Nehradit]>=(0) AND [Nehradit]<=(1)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__Nehradit]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__OsvobozenaPlneni] CHECK  (([OsvobozenaPlneni]=(3) OR [OsvobozenaPlneni]=(2) OR [OsvobozenaPlneni]=(1) OR [OsvobozenaPlneni]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__OsvobozenaPlneni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__PotvrDoruceni] CHECK  (([DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(13) OR [PotvrDoruceni]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__PotvrDoruceni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__PoziceZaokrDPH] CHECK  (([PoziceZaokrDPH]=(127) OR [PoziceZaokrDPH]=(126) OR [PoziceZaokrDPH]=(3) OR [PoziceZaokrDPH]=(2) OR [PoziceZaokrDPH]=(1) OR [PoziceZaokrDPH]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__PoziceZaokrDPH]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__RezimMOSS] CHECK  (([RezimMOSS]=(3) OR [RezimMOSS]=(2) OR [RezimMOSS]=(1) OR [RezimMOSS]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__RezimMOSS]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__SplatnoPocitatOd] CHECK  (([SplatnoPocitatOd]=(11) OR [SplatnoPocitatOd]=(10) OR [SplatnoPocitatOd]=(8) OR [SplatnoPocitatOd]=(6) OR [SplatnoPocitatOd]=(5) OR [SplatnoPocitatOd]=(4) OR [SplatnoPocitatOd]=(3) OR [SplatnoPocitatOd]=(2) OR [SplatnoPocitatOd]=(1) OR [SplatnoPocitatOd]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__SplatnoPocitatOd]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__StavEET] CHECK  (([StavEET]>=(0) AND [StavEET]<=(3)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__StavEET]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__StavFakturace] CHECK  (([StavFakturace]=N'X' OR [StavFakturace]=N'/' OR [StavFakturace]=N' '))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__StavFakturace]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__StavNahPlneni] CHECK  (([StavNahPlneni]>=(0) AND [StavNahPlneni]<=(5) AND ([StavNahPlneni]=(0) OR ([DruhPohybuZbo]=(19) OR [DruhPohybuZbo]=(18) OR [DruhPohybuZbo]=(14) OR [DruhPohybuZbo]=(13)))))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__StavNahPlneni]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__StavRezervace] CHECK  (([StavRezervace]=N'X' OR [StavRezervace]=N'/' OR [StavRezervace]=N' '))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__StavRezervace]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__StavZalFak] CHECK  (([StavZalFak]>=(0) AND [StavZalFak]<=(5)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__StavZalFak]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__VstupniCena] CHECK  (([VstupniCena]>=(0) AND [VstupniCena]<=(11)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__VstupniCena]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__ZaokrDPHMalaCisla] CHECK  (([ZaokrDPHMalaCisla]>=(0) AND [ZaokrDPHMalaCisla]<=(1)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__ZaokrDPHMalaCisla]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__ZaokrDPHvaluty] CHECK  (([ZaokrDPHvaluty]>=(0) AND [ZaokrDPHvaluty]<=(1)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__ZaokrDPHvaluty]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__ZaokrNaPadesat] CHECK  (([ZaokrNaPadesat]=(7) OR [ZaokrNaPadesat]=(6) OR [ZaokrNaPadesat]=(4) OR [ZaokrNaPadesat]=(2) OR [ZaokrNaPadesat]=(1) OR [ZaokrNaPadesat]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__ZaokrNaPadesat]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__ZboziSluzba] CHECK  (([ZboziSluzba]=(2) OR [ZboziSluzba]=(1) OR [ZboziSluzba]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__ZboziSluzba]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__ZdrojCisKV] CHECK  (([ZdrojCisKV]=(2) OR [ZdrojCisKV]=(1) OR [ZdrojCisKV]=(0)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__ZdrojCisKV]
GO

ALTER TABLE [dbo].[TabDokladyZbozi]  WITH CHECK ADD  CONSTRAINT [CK__TabDokladyZbozi__ZpusobKurzZal] CHECK  (([ZpusobKurzZal]>=(0) AND [ZpusobKurzZal]<=(2)))
GO

ALTER TABLE [dbo].[TabDokladyZbozi] CHECK CONSTRAINT [CK__TabDokladyZbozi__ZpusobKurzZal]
GO

