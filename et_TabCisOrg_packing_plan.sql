USE [HCvicna]
GO

/****** Object:  Table [dbo].[TabCisOrg]    Script Date: 02.07.2025 13:24:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TabCisOrg](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CisloOrg] [int] NOT NULL,
	[NadrizenaOrg] [int] NULL,
	[Nazev] [nvarchar](255) NOT NULL,
	[DruhyNazev] [nvarchar](100) NOT NULL,
	[Misto] [nvarchar](100) NOT NULL,
	[IdZeme] [nvarchar](3) NULL,
	[Region] [nvarchar](15) NULL,
	[Ulice] [nvarchar](100) NOT NULL,
	[PSC] [nvarchar](10) NULL,
	[PoBox] [nvarchar](40) NULL,
	[Kontakt] [nvarchar](40) NULL,
	[DIC] [nvarchar](15) NULL,
	[LhutaSplatnosti] [smallint] NULL,
	[Stav] [tinyint] NOT NULL,
	[PravniForma] [tinyint] NOT NULL,
	[DruhCinnosti] [int] NULL,
	[ICO] [nvarchar](20) NULL,
	[Sleva] [numeric](5, 2) NOT NULL,
	[OdHodnoty] [numeric](19, 6) NOT NULL,
	[CenovaUroven] [int] NULL,
	[IDSOZsleva] [int] NULL,
	[IDSOZnazev] [int] NULL,
	[Poznamka] [ntext] NULL,
	[FormaUhrady] [nvarchar](30) NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[JeOdberatel] [bit] NOT NULL,
	[JeDodavatel] [bit] NOT NULL,
	[OdpOs] [int] NULL,
	[Upozorneni] [nvarchar](255) NULL,
	[CisloOrgDos] [nvarchar](20) NOT NULL,
	[Mena] [nvarchar](3) NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatZmeny] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
	[Fakturacni] [bit] NOT NULL,
	[MU] [bit] NOT NULL,
	[Prijemce] [bit] NOT NULL,
	[UdajOZapisuDoObchRej] [nvarchar](128) NOT NULL,
	[IDBankSpojeni] [int] NULL,
	[CarovyKodEAN] [nvarchar](13) NULL,
	[PostAddress] [nvarchar](255) NOT NULL,
	[Kredit] [numeric](19, 6) NOT NULL,
	[Saldo] [numeric](19, 6) NOT NULL,
	[UhrazenoPredSpl1] [numeric](19, 6) NOT NULL,
	[UhrazenoPredSpl2] [numeric](19, 6) NOT NULL,
	[UhrazenoPredSpl3] [numeric](19, 6) NOT NULL,
	[UhrazenoPredSpl4] [numeric](19, 6) NOT NULL,
	[UhrazenoPredSpl5] [numeric](19, 6) NOT NULL,
	[UhrazenoPredSpl6] [numeric](19, 6) NOT NULL,
	[UhrazenoPredSpl0] [numeric](19, 6) NOT NULL,
	[UhrazenoPoSpl1] [numeric](19, 6) NOT NULL,
	[UhrazenoPoSpl2] [numeric](19, 6) NOT NULL,
	[UhrazenoPoSpl3] [numeric](19, 6) NOT NULL,
	[UhrazenoPoSpl4] [numeric](19, 6) NOT NULL,
	[UhrazenoPoSpl5] [numeric](19, 6) NOT NULL,
	[UhrazenoPoSpl6] [numeric](19, 6) NOT NULL,
	[UhrazenoPoSpl0] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPredSpl1] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPredSpl2] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPredSpl3] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPredSpl4] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPredSpl5] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPredSpl6] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPredSpl0] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPoSpl1] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPoSpl2] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPoSpl3] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPoSpl4] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPoSpl5] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPoSpl6] [numeric](19, 6) NOT NULL,
	[NeuhrazenoPoSpl0] [numeric](19, 6) NOT NULL,
	[FaSumaCelkem] [numeric](19, 6) NULL,
	[PozastavenoCelkem] [numeric](19, 6) NULL,
	[FaAktualizovano] [datetime] NULL,
	[PlneniBezDPH] [bit] NOT NULL,
	[Jazyk] [nvarchar](15) NULL,
	[DatumNeupominani] [datetime] NULL,
	[CenovaUrovenNakup] [int] NULL,
	[TIN] [nvarchar](17) NOT NULL,
	[EvCisDanovySklad] [nvarchar](30) NULL,
	[SlevaSozNa] [tinyint] NULL,
	[SlevaSkupZbo] [tinyint] NULL,
	[SlevaKmenZbo] [tinyint] NULL,
	[SlevaStavSkladu] [tinyint] NULL,
	[SlevaZbozi] [tinyint] NULL,
	[SlevaOrg] [tinyint] NULL,
	[DICsk] [nvarchar](15) NULL,
	[IdTxtPenFak] [int] NULL,
	[OrCislo] [nvarchar](15) NOT NULL,
	[PopCislo] [nvarchar](15) NOT NULL,
	[VernostniProgram] [bit] NOT NULL,
	[Logo] [varbinary](max) NULL,
	[KorekceSplatnoAuto] [int] NOT NULL,
	[KorekceSplatnoUziv] [int] NOT NULL,
	[NapocetProPT] [tinyint] NOT NULL,
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
	[KreditZustatek]  AS (CONVERT([numeric](19,6),[Kredit]-[Saldo],0)),
	[FaAktualizovano_D]  AS (datepart(day,[FaAktualizovano])),
	[FaAktualizovano_M]  AS (datepart(month,[FaAktualizovano])),
	[FaAktualizovano_Y]  AS (datepart(year,[FaAktualizovano])),
	[FaAktualizovano_Q]  AS (datepart(quarter,[FaAktualizovano])),
	[FaAktualizovano_W]  AS (datepart(week,[FaAktualizovano])),
	[FaAktualizovano_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[FaAktualizovano],0),0),0)),
	[DatumNeupominani_D]  AS (datepart(day,[DatumNeupominani])),
	[DatumNeupominani_M]  AS (datepart(month,[DatumNeupominani])),
	[DatumNeupominani_Y]  AS (datepart(year,[DatumNeupominani])),
	[DatumNeupominani_Q]  AS (datepart(quarter,[DatumNeupominani])),
	[DatumNeupominani_W]  AS (datepart(week,[DatumNeupominani])),
	[DatumNeupominani_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumNeupominani],0),0),0)),
	[IDBankSpojPlatak] [int] NULL,
	[EORI] [nvarchar](17) NOT NULL,
	[DruhDopravy] [tinyint] NULL,
	[DodaciPodminky] [nvarchar](3) NOT NULL,
	[KorekceSplatnoUzivD] [int] NOT NULL,
	[RezimPenalizace] [tinyint] NOT NULL,
	[Penale] [tinyint] NOT NULL,
	[Partner] [nvarchar](7) NULL,
	[PlatceDPH] [bit] NOT NULL,
	[IDSOZExpirace] [int] NULL,
	[NazevOkresu] [nvarchar](100) NOT NULL,
	[NazevCastiObce] [nvarchar](100) NOT NULL,
	[MestskaCast] [nvarchar](100) NOT NULL,
	[KodAdrMista] [int] NULL,
	[NespolehPlatce] [tinyint] NOT NULL,
	[AktZWebuNespolehPlatce] [bit] NOT NULL,
	[AktZWebuZverejBankUcty] [bit] NOT NULL,
	[DatZverejNespolehPlatce] [datetime] NULL,
	[DatZverejNespolehPlatce_D]  AS (datepart(day,[DatZverejNespolehPlatce])),
	[DatZverejNespolehPlatce_M]  AS (datepart(month,[DatZverejNespolehPlatce])),
	[DatZverejNespolehPlatce_Y]  AS (datepart(year,[DatZverejNespolehPlatce])),
	[DatZverejNespolehPlatce_Q]  AS (datepart(quarter,[DatZverejNespolehPlatce])),
	[DatZverejNespolehPlatce_W]  AS (datepart(week,[DatZverejNespolehPlatce])),
	[DatZverejNespolehPlatce_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZverejNespolehPlatce],0),0),0)),
	[DatPoslOverNespolehPlatceSys] [datetime] NULL,
	[DatPoslOverNespolehPlatceUziv] [datetime] NULL,
	[ZajisteniDPHCisloFU] [nvarchar](20) NOT NULL,
	[ZajisteniDPHJinyDuvodRuceni] [tinyint] NOT NULL,
	[ZajisteniDPHJinyDuvodRuceniDatZverej] [datetime] NULL,
	[DatPoslOverNespolehPlatceSys_D]  AS (datepart(day,[DatPoslOverNespolehPlatceSys])),
	[DatPoslOverNespolehPlatceSys_M]  AS (datepart(month,[DatPoslOverNespolehPlatceSys])),
	[DatPoslOverNespolehPlatceSys_Y]  AS (datepart(year,[DatPoslOverNespolehPlatceSys])),
	[DatPoslOverNespolehPlatceSys_Q]  AS (datepart(quarter,[DatPoslOverNespolehPlatceSys])),
	[DatPoslOverNespolehPlatceSys_W]  AS (datepart(week,[DatPoslOverNespolehPlatceSys])),
	[DatPoslOverNespolehPlatceSys_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPoslOverNespolehPlatceSys],0),0),0)),
	[DatPoslOverNespolehPlatceUziv_D]  AS (datepart(day,[DatPoslOverNespolehPlatceUziv])),
	[DatPoslOverNespolehPlatceUziv_M]  AS (datepart(month,[DatPoslOverNespolehPlatceUziv])),
	[DatPoslOverNespolehPlatceUziv_Y]  AS (datepart(year,[DatPoslOverNespolehPlatceUziv])),
	[DatPoslOverNespolehPlatceUziv_Q]  AS (datepart(quarter,[DatPoslOverNespolehPlatceUziv])),
	[DatPoslOverNespolehPlatceUziv_W]  AS (datepart(week,[DatPoslOverNespolehPlatceUziv])),
	[DatPoslOverNespolehPlatceUziv_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPoslOverNespolehPlatceUziv],0),0),0)),
	[ZajisteniDPHJinyDuvodRuceniDatZverej_D]  AS (datepart(day,[ZajisteniDPHJinyDuvodRuceniDatZverej])),
	[ZajisteniDPHJinyDuvodRuceniDatZverej_M]  AS (datepart(month,[ZajisteniDPHJinyDuvodRuceniDatZverej])),
	[ZajisteniDPHJinyDuvodRuceniDatZverej_Y]  AS (datepart(year,[ZajisteniDPHJinyDuvodRuceniDatZverej])),
	[ZajisteniDPHJinyDuvodRuceniDatZverej_Q]  AS (datepart(quarter,[ZajisteniDPHJinyDuvodRuceniDatZverej])),
	[ZajisteniDPHJinyDuvodRuceniDatZverej_W]  AS (datepart(week,[ZajisteniDPHJinyDuvodRuceniDatZverej])),
	[ZajisteniDPHJinyDuvodRuceniDatZverej_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[ZajisteniDPHJinyDuvodRuceniDatZverej],0),0),0)),
	[PartnerICO] [nvarchar](20) NULL,
	[LhutaSplatnostiDodavatel] [smallint] NULL,
	[KonsolidaceStatu] [bit] NOT NULL,
	[Legislativa] [tinyint] NOT NULL,
	[Logo_DatLen]  AS (isnull(datalength([Logo]),(0))),
	[DICDPHVystup] [nvarchar](15) NULL,
	[GPSZemepisnaSirka] [numeric](10, 7) NULL,
	[GPSZemepisnaDelka] [numeric](10, 7) NULL,
	[RUIANCislo]  AS (substring(substring(replace([OrCislo],' ',''),patindex('%[0-9]%',replace([OrCislo],' ','')),(50)),(1),case when patindex('%[^0-9]%',substring(replace([OrCislo],' ',''),patindex('%[0-9]%',replace([OrCislo],' ','')),(50)))>(0) then patindex('%[^0-9]%',substring(replace([OrCislo],' ',''),patindex('%[0-9]%',replace([OrCislo],' ','')),(50)))-(1) else (50) end)),
	[RUIANPismeno]  AS (substring(substring(replace([OrCislo],' ',''),patindex('%[a-z]%',replace([OrCislo],' ','')),(10)),(1),case when patindex('%[^a-z]%',substring(replace([OrCislo],' ',''),patindex('%[a-z]%',replace([OrCislo],' ','')),(10)))>(0) then patindex('%[^a-z]%',substring(replace([OrCislo],' ',''),patindex('%[a-z]%',replace([OrCislo],' ','')),(10)))-(1) else (10) end)),
	[JePartner] [bit] NOT NULL,
	[EmailSouhlas] [bit] NOT NULL,
	[IDKonOs] [int] NULL,
	[IDKateg] [int] NULL,
	[Obrat] [numeric](19, 2) NULL,
	[PocetZam] [int] NULL,
	[PZ2Vstup] [bit] NOT NULL,
	[PZ2Vystup] [bit] NOT NULL,
	[PZ2PoradiVstup] [int] NOT NULL,
	[PZ2PoradiVystup] [int] NOT NULL,
	[DatumCasPoslSynchr] [datetime] NULL,
	[DatumCasPoslSynchr_D]  AS (datepart(day,[DatumCasPoslSynchr])),
	[DatumCasPoslSynchr_M]  AS (datepart(month,[DatumCasPoslSynchr])),
	[DatumCasPoslSynchr_Y]  AS (datepart(year,[DatumCasPoslSynchr])),
	[DatumCasPoslSynchr_Q]  AS (datepart(quarter,[DatumCasPoslSynchr])),
	[DatumCasPoslSynchr_W]  AS (datepart(week,[DatumCasPoslSynchr])),
	[DatumCasPoslSynchr_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumCasPoslSynchr])))),
	[IDZdrojOsUdaju] [int] NULL,
	[OmezeniZpracOU] [bit] NOT NULL,
	[JeNovaVetaEditor] [bit] NOT NULL,
	[FormaDopravy] [nvarchar](30) NULL,
	[SKDPHPlatceNaZruseni] [bit] NOT NULL,
	[Agent] [bit] NOT NULL,
	[Firma]  AS (ltrim(substring(replace([Nazev],nchar((13))+nchar((10)),nchar((32))),(1),(255)))),
	[AktOrgDleRegistru] [bit] NOT NULL,
	[LimitPlatHotovKontrola] [bit] NOT NULL,
	[HraniceMarze] [numeric](5, 2) NULL,
	[PouzitMarzeOdDo] [bit] NOT NULL,
	[UliceSCisly]  AS (([Ulice]+case when [Ulice]<>'' then N' ' else [NazevCastiObce]+case when [NazevCastiObce]<>'' then N' ' else case when [PopCislo]='' then '' else N'č. p. ' end end end)+case when [PopCislo]<>'' AND [OrCislo]<>'' then ([PopCislo]+N'/')+[OrCislo] else [PopCislo]+[OrCislo] end),
	[PostovniAdresa]  AS (CONVERT([nvarchar](255),case when [PostAddress]='' then (((((([Nazev]+nchar((13)))+nchar((10)))+(([Ulice]+case when [Ulice]<>'' then N' ' else [NazevCastiObce]+case when [NazevCastiObce]<>'' then N' ' else case when [PopCislo]='' then '' else N'č. p. ' end end end)+case when [PopCislo]<>'' AND [OrCislo]<>'' then ([PopCislo]+N'/')+[OrCislo] else [PopCislo]+[OrCislo] end))+nchar((13)))+nchar((10)))+ltrim(isnull([PSC],'')+nchar((32))))+[Misto] else [PostAddress] end)),
	[Prijmeni] [nvarchar](100) NOT NULL,
	[Jmeno] [nvarchar](100) NOT NULL,
	[RodneCislo] [nvarchar](11) NOT NULL,
	[DatumNarozeni] [datetime] NULL,
	[UcetPohledavky] [nvarchar](30) NULL,
	[UcetZavazku] [nvarchar](30) NULL,
	[UcetZalPrij] [nvarchar](30) NULL,
	[UcetZalVyd] [nvarchar](30) NULL,
	[DatumNarozeni_D]  AS (datepart(day,[DatumNarozeni])),
	[DatumNarozeni_M]  AS (datepart(month,[DatumNarozeni])),
	[DatumNarozeni_Y]  AS (datepart(year,[DatumNarozeni])),
	[DatumNarozeni_Q]  AS (datepart(quarter,[DatumNarozeni])),
	[DatumNarozeni_W]  AS (datepart(week,[DatumNarozeni])),
	[DatumNarozeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumNarozeni])))),
	[NastavDatSplatPocOdFV] [tinyint] NOT NULL,
	[NastavDatSplatPocOdFP] [tinyint] NOT NULL,
	[UcetOstPohl] [nvarchar](30) NULL,
	[UcetOstZavaz] [nvarchar](30) NULL,
	[AktZWebuZverejBankUctySK] [bit] NOT NULL,
	[DatPoslOverBankySysSK] [datetime] NULL,
	[DatPoslOverBankySysSK_D]  AS (datepart(day,[DatPoslOverBankySysSK])),
	[DatPoslOverBankySysSK_M]  AS (datepart(month,[DatPoslOverBankySysSK])),
	[DatPoslOverBankySysSK_Y]  AS (datepart(year,[DatPoslOverBankySysSK])),
	[DatPoslOverBankySysSK_Q]  AS (datepart(quarter,[DatPoslOverBankySysSK])),
	[DatPoslOverBankySysSK_W]  AS (datepart(week,[DatPoslOverBankySysSK])),
	[DatPoslOverBankySysSK_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPoslOverBankySysSK])))),
	[AutoUPOMPF_JakaMena] [tinyint] NOT NULL,
	[AutoUPOMPF_Mena] [nvarchar](3) NULL,
	[AutoUPOMPF_Upominat] [bit] NOT NULL,
	[AutoUPOMPF_UpomPo] [tinyint] NOT NULL,
	[AutoUPOMPF_UpomPoDnu] [smallint] NULL,
	[AutoUPOMPF_UpomOd] [tinyint] NOT NULL,
	[AutoUPOMPF_UpomOdCastka] [numeric](19, 6) NULL,
	[AutoUPOMPF_Penalizovat] [bit] NOT NULL,
	[AutoUPOMPF_PenalPo] [tinyint] NOT NULL,
	[AutoUPOMPF_PenalPoDnu] [smallint] NULL,
	[AutoUPOMPF_PenalOd] [tinyint] NOT NULL,
	[AutoUPOMPF_PenalOdCastka] [numeric](19, 6) NULL,
	[VstupniCenaDod] [tinyint] NOT NULL,
	[VstupniCenaOdb] [tinyint] NOT NULL,
	[SystemRowVersion] [timestamp] NOT NULL,
	[SystemRowVersionText]  AS (CONVERT([nvarchar](16),CONVERT([binary](8),[SystemRowVersion]),(2))),
	[AresDatumAktualizaceRegistru] [datetime] NULL,
	[AVAReferenceID] [nvarchar](40) NOT NULL,
	[AVAExternalID] [nvarchar](255) NOT NULL,
	[AresDatumAktualizaceRegistru_D]  AS (datepart(day,[AresDatumAktualizaceRegistru])),
	[AresDatumAktualizaceRegistru_M]  AS (datepart(month,[AresDatumAktualizaceRegistru])),
	[AresDatumAktualizaceRegistru_Y]  AS (datepart(year,[AresDatumAktualizaceRegistru])),
	[AresDatumAktualizaceRegistru_Q]  AS (datepart(quarter,[AresDatumAktualizaceRegistru])),
	[AresDatumAktualizaceRegistru_W]  AS (datepart(week,[AresDatumAktualizaceRegistru])),
	[AresDatumAktualizaceRegistru_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[AresDatumAktualizaceRegistru])))),
	[AVAOutputFlag] [tinyint] NOT NULL,
	[AVASentDate] [datetime] NULL,
	[AVASentDate_D]  AS (datepart(day,[AVASentDate])),
	[AVASentDate_M]  AS (datepart(month,[AVASentDate])),
	[AVASentDate_Y]  AS (datepart(year,[AVASentDate])),
	[AVASentDate_Q]  AS (datepart(quarter,[AVASentDate])),
	[AVASentDate_W]  AS (datepart(week,[AVASentDate])),
	[AVASentDate_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[AVASentDate])))),
	[DnyToleranceScontaFaV] [int] NULL,
	[Logo_BGJ]  AS (case when [Logo] IS NULL then NULL else case when substring([Logo],(1),(2))=0x424D then N'Bitmap' else case when substring([Logo],(1),(3))=0x474946 then N'GIF' else case when substring([Logo],(1),(2))=0xFFD8 then N'JPEG' else case when substring([Logo],(1),(4))=0x00000100 then N'Icon' else case when substring([Logo],(1),(8))=0x89504E470D0A1A0A then N'PNG' else case when substring([Logo],(1),(4))=0x54494646 then N'TIFF' else case when substring([Logo],(1),(4))=0x25504446 then N'PDF' else case when substring([Logo],(1),(4))=0x52494646 AND substring([Logo],(9),(4))=0x57454250 then N'WEBP' else case when charindex(0x3C737667,substring([Logo],(1),(500)))>(0) then N'SVG' else '' end end end end end end end end end end),
	[AutoUPOMPF_UpomDoDnu] [smallint] NULL,
 CONSTRAINT [PK__TabCisOrg__CisloOrg] PRIMARY KEY CLUSTERED 
(
	[CisloOrg] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__TabCisOrg__AVAReferenceID] UNIQUE NONCLUSTERED 
(
	[AVAReferenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__TabCisOrg__ID] UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Nazev]  DEFAULT ('') FOR [Nazev]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__DruhyNazev]  DEFAULT ('') FOR [DruhyNazev]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Misto]  DEFAULT ('') FOR [Misto]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Ulice]  DEFAULT ('') FOR [Ulice]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Stav]  DEFAULT ((0)) FOR [Stav]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PravniForma]  DEFAULT ((0)) FOR [PravniForma]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Sleva]  DEFAULT ((0.0)) FOR [Sleva]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__OdHodnoty]  DEFAULT ((0.0)) FOR [OdHodnoty]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__JeOdberatel]  DEFAULT ((0)) FOR [JeOdberatel]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__JeDodavatel]  DEFAULT ((0)) FOR [JeDodavatel]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__CisloOrgDos]  DEFAULT ('') FOR [CisloOrgDos]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Fakturacni]  DEFAULT ((0)) FOR [Fakturacni]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__MU]  DEFAULT ((0)) FOR [MU]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Prijemce]  DEFAULT ((0)) FOR [Prijemce]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UdajOZapisuDoObchRej]  DEFAULT ('') FOR [UdajOZapisuDoObchRej]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PostAddress]  DEFAULT ('') FOR [PostAddress]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Kredit]  DEFAULT ((0.0)) FOR [Kredit]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Saldo]  DEFAULT ((0.0)) FOR [Saldo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPredSpl1]  DEFAULT ((0.0)) FOR [UhrazenoPredSpl1]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPredSpl2]  DEFAULT ((0.0)) FOR [UhrazenoPredSpl2]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPredSpl3]  DEFAULT ((0.0)) FOR [UhrazenoPredSpl3]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPredSpl4]  DEFAULT ((0.0)) FOR [UhrazenoPredSpl4]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPredSpl5]  DEFAULT ((0.0)) FOR [UhrazenoPredSpl5]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPredSpl6]  DEFAULT ((0.0)) FOR [UhrazenoPredSpl6]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPredSpl0]  DEFAULT ((0.0)) FOR [UhrazenoPredSpl0]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPoSpl1]  DEFAULT ((0.0)) FOR [UhrazenoPoSpl1]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPoSpl2]  DEFAULT ((0.0)) FOR [UhrazenoPoSpl2]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPoSpl3]  DEFAULT ((0.0)) FOR [UhrazenoPoSpl3]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPoSpl4]  DEFAULT ((0.0)) FOR [UhrazenoPoSpl4]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPoSpl5]  DEFAULT ((0.0)) FOR [UhrazenoPoSpl5]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPoSpl6]  DEFAULT ((0.0)) FOR [UhrazenoPoSpl6]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__UhrazenoPoSpl0]  DEFAULT ((0.0)) FOR [UhrazenoPoSpl0]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPredSpl1]  DEFAULT ((0.0)) FOR [NeuhrazenoPredSpl1]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPredSpl2]  DEFAULT ((0.0)) FOR [NeuhrazenoPredSpl2]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPredSpl3]  DEFAULT ((0.0)) FOR [NeuhrazenoPredSpl3]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPredSpl4]  DEFAULT ((0.0)) FOR [NeuhrazenoPredSpl4]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPredSpl5]  DEFAULT ((0.0)) FOR [NeuhrazenoPredSpl5]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPredSpl6]  DEFAULT ((0.0)) FOR [NeuhrazenoPredSpl6]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPredSpl0]  DEFAULT ((0.0)) FOR [NeuhrazenoPredSpl0]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPoSpl1]  DEFAULT ((0.0)) FOR [NeuhrazenoPoSpl1]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPoSpl2]  DEFAULT ((0.0)) FOR [NeuhrazenoPoSpl2]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPoSpl3]  DEFAULT ((0.0)) FOR [NeuhrazenoPoSpl3]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPoSpl4]  DEFAULT ((0.0)) FOR [NeuhrazenoPoSpl4]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPoSpl5]  DEFAULT ((0.0)) FOR [NeuhrazenoPoSpl5]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPoSpl6]  DEFAULT ((0.0)) FOR [NeuhrazenoPoSpl6]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NeuhrazenoPoSpl0]  DEFAULT ((0.0)) FOR [NeuhrazenoPoSpl0]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__FaSumaCelkem]  DEFAULT ((0.0)) FOR [FaSumaCelkem]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PozastavenoCelkem]  DEFAULT ((0.0)) FOR [PozastavenoCelkem]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PlneniBezDPH]  DEFAULT ((0)) FOR [PlneniBezDPH]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__TIN]  DEFAULT ('') FOR [TIN]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__SlevaSozNa]  DEFAULT ((2)) FOR [SlevaSozNa]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__SlevaSkupZbo]  DEFAULT ((2)) FOR [SlevaSkupZbo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__SlevaKmenZbo]  DEFAULT ((2)) FOR [SlevaKmenZbo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__SlevaStavSkladu]  DEFAULT ((2)) FOR [SlevaStavSkladu]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__SlevaZbozi]  DEFAULT ((2)) FOR [SlevaZbozi]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__SlevaOrg]  DEFAULT ((2)) FOR [SlevaOrg]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__OrCislo]  DEFAULT ('') FOR [OrCislo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PopCislo]  DEFAULT ('') FOR [PopCislo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__VernostniProgram]  DEFAULT ((0)) FOR [VernostniProgram]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__KorekceSplatnoAuto]  DEFAULT ((0)) FOR [KorekceSplatnoAuto]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__KorekceSplatnoUziv]  DEFAULT ((0)) FOR [KorekceSplatnoUziv]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NapocetProPT]  DEFAULT ((0)) FOR [NapocetProPT]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__EORI]  DEFAULT ('') FOR [EORI]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__DodaciPodminky]  DEFAULT ('') FOR [DodaciPodminky]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__KorekceSplatnoUzivD]  DEFAULT ((0)) FOR [KorekceSplatnoUzivD]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__RezimPenalizace]  DEFAULT ((0)) FOR [RezimPenalizace]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Penale]  DEFAULT ((0)) FOR [Penale]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PlatceDPH]  DEFAULT ((0)) FOR [PlatceDPH]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NazevOkresu]  DEFAULT ('') FOR [NazevOkresu]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NazevCastiObce]  DEFAULT ('') FOR [NazevCastiObce]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__MestskaCast]  DEFAULT ('') FOR [MestskaCast]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NespolehPlatce]  DEFAULT ((3)) FOR [NespolehPlatce]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AktZWebuNespolehPlatce]  DEFAULT ((0)) FOR [AktZWebuNespolehPlatce]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AktZWebuZverejBankUcty]  DEFAULT ((0)) FOR [AktZWebuZverejBankUcty]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__ZajisteniDPHCisloFU]  DEFAULT ('') FOR [ZajisteniDPHCisloFU]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__ZajisteniDPHJinyDuvodRuceni]  DEFAULT ((0)) FOR [ZajisteniDPHJinyDuvodRuceni]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__KonsolidaceStatu]  DEFAULT ((0)) FOR [KonsolidaceStatu]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Legislativa]  DEFAULT ((0)) FOR [Legislativa]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__JePartner]  DEFAULT ((0)) FOR [JePartner]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__EmailSouhlas]  DEFAULT ((0)) FOR [EmailSouhlas]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PZ2Vstup]  DEFAULT ((0)) FOR [PZ2Vstup]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PZ2Vystup]  DEFAULT ((0)) FOR [PZ2Vystup]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PZ2PoradiVstup]  DEFAULT ((0)) FOR [PZ2PoradiVstup]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PZ2PoradiVystup]  DEFAULT ((0)) FOR [PZ2PoradiVystup]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__OmezeniZpracOU]  DEFAULT ((0)) FOR [OmezeniZpracOU]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__JeNovaVetaEditor]  DEFAULT ((0)) FOR [JeNovaVetaEditor]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__SKDPHPlatceNaZruseni]  DEFAULT ((0)) FOR [SKDPHPlatceNaZruseni]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Agent]  DEFAULT ((0)) FOR [Agent]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AktOrgDleRegistru]  DEFAULT ((1)) FOR [AktOrgDleRegistru]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__LimitPlatHotovKontrola]  DEFAULT ((1)) FOR [LimitPlatHotovKontrola]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__PouzitMarzeOdDo]  DEFAULT ((0)) FOR [PouzitMarzeOdDo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Prijmeni]  DEFAULT ('') FOR [Prijmeni]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__Jmeno]  DEFAULT ('') FOR [Jmeno]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__RodneCislo]  DEFAULT ('') FOR [RodneCislo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NastavDatSplatPocOdFV]  DEFAULT ((100)) FOR [NastavDatSplatPocOdFV]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__NastavDatSplatPocOdFP]  DEFAULT ((100)) FOR [NastavDatSplatPocOdFP]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AktZWebuZverejBankUctySK]  DEFAULT ((0)) FOR [AktZWebuZverejBankUctySK]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_JakaMena]  DEFAULT ((0)) FOR [AutoUPOMPF_JakaMena]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_Upominat]  DEFAULT ((1)) FOR [AutoUPOMPF_Upominat]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_UpomPo]  DEFAULT ((0)) FOR [AutoUPOMPF_UpomPo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_UpomOd]  DEFAULT ((0)) FOR [AutoUPOMPF_UpomOd]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_UpomOdCastka]  DEFAULT ((0)) FOR [AutoUPOMPF_UpomOdCastka]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_Penalizovat]  DEFAULT ((1)) FOR [AutoUPOMPF_Penalizovat]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_PenalPo]  DEFAULT ((0)) FOR [AutoUPOMPF_PenalPo]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_PenalOd]  DEFAULT ((0)) FOR [AutoUPOMPF_PenalOd]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AutoUPOMPF_PenalOdCastka]  DEFAULT ((0)) FOR [AutoUPOMPF_PenalOdCastka]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__VstupniCenaDod]  DEFAULT ((100)) FOR [VstupniCenaDod]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__VstupniCenaOdb]  DEFAULT ((100)) FOR [VstupniCenaOdb]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AVAReferenceID]  DEFAULT (CONVERT([nvarchar](36),CONVERT([uniqueidentifier],newid()))) FOR [AVAReferenceID]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AVAExternalID]  DEFAULT ('') FOR [AVAExternalID]
GO

ALTER TABLE [dbo].[TabCisOrg] ADD  CONSTRAINT [DF__TabCisOrg__AVAOutputFlag]  DEFAULT ((0)) FOR [AVAOutputFlag]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__AutoUPOMPF_Mena] FOREIGN KEY([AutoUPOMPF_Mena])
REFERENCES [dbo].[TabKodMen] ([Kod])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__AutoUPOMPF_Mena]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__CenovaUroven] FOREIGN KEY([CenovaUroven])
REFERENCES [dbo].[TabCisNC] ([CenovaUroven])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__CenovaUroven]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__CenovaUrovenNakup] FOREIGN KEY([CenovaUrovenNakup])
REFERENCES [dbo].[TabCisNC] ([CenovaUroven])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__CenovaUrovenNakup]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__DruhCinnosti] FOREIGN KEY([DruhCinnosti])
REFERENCES [dbo].[TabDruhCinnosti] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__DruhCinnosti]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__FormaDopravy] FOREIGN KEY([FormaDopravy])
REFERENCES [dbo].[TabFormaDopravy] ([FormaDopravy])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__FormaDopravy]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__FormaUhrady] FOREIGN KEY([FormaUhrady])
REFERENCES [dbo].[TabFormaUhrady] ([FormaUhrady])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__FormaUhrady]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IDBankSpojeni] FOREIGN KEY([IDBankSpojeni])
REFERENCES [dbo].[TabBankSpojeni] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IDBankSpojeni]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IDBankSpojPlatak] FOREIGN KEY([IDBankSpojPlatak])
REFERENCES [dbo].[TabBankSpojeni] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IDBankSpojPlatak]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IDKateg] FOREIGN KEY([IDKateg])
REFERENCES [dbo].[TabKategOrg] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IDKateg]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IDKonOs] FOREIGN KEY([IDKonOs])
REFERENCES [dbo].[TabCisKOs] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IDKonOs]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IDSOZExpirace] FOREIGN KEY([IDSOZExpirace])
REFERENCES [dbo].[TabSoz] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IDSOZExpirace]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IDSOZnazev] FOREIGN KEY([IDSOZnazev])
REFERENCES [dbo].[TabSoz] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IDSOZnazev]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IDSOZsleva] FOREIGN KEY([IDSOZsleva])
REFERENCES [dbo].[TabSoz] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IDSOZsleva]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IdTxtPenFak] FOREIGN KEY([IdTxtPenFak])
REFERENCES [dbo].[TabTxtUpo] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IdTxtPenFak]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IDZdrojOsUdaju] FOREIGN KEY([IDZdrojOsUdaju])
REFERENCES [dbo].[TabZdrojeOsUdaju] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IDZdrojOsUdaju]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__IdZeme] FOREIGN KEY([IdZeme])
REFERENCES [dbo].[TabZeme] ([ISOKod])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__IdZeme]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__Jazyk] FOREIGN KEY([Jazyk])
REFERENCES [dbo].[TabJazyky] ([Jazyk])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__Jazyk]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__Mena] FOREIGN KEY([Mena])
REFERENCES [dbo].[TabKodMen] ([Kod])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__Mena]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__NadrizenaOrg] FOREIGN KEY([NadrizenaOrg])
REFERENCES [dbo].[TabCisOrg] ([CisloOrg])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__NadrizenaOrg]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__OdpOs] FOREIGN KEY([OdpOs])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__OdpOs]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__Region] FOREIGN KEY([Region])
REFERENCES [dbo].[TabRegion] ([Cislo])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__Region]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__UcetOstPohl] FOREIGN KEY([UcetOstPohl])
REFERENCES [dbo].[TabCisUct] ([CisloUcet])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__UcetOstPohl]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__UcetOstZavaz] FOREIGN KEY([UcetOstZavaz])
REFERENCES [dbo].[TabCisUct] ([CisloUcet])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__UcetOstZavaz]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__UcetPohledavky] FOREIGN KEY([UcetPohledavky])
REFERENCES [dbo].[TabCisUct] ([CisloUcet])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__UcetPohledavky]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__UcetZalPrij] FOREIGN KEY([UcetZalPrij])
REFERENCES [dbo].[TabCisUct] ([CisloUcet])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__UcetZalPrij]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__UcetZalVyd] FOREIGN KEY([UcetZalVyd])
REFERENCES [dbo].[TabCisUct] ([CisloUcet])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__UcetZalVyd]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [FK__TabCisOrg__UcetZavazku] FOREIGN KEY([UcetZavazku])
REFERENCES [dbo].[TabCisUct] ([CisloUcet])
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [FK__TabCisOrg__UcetZavazku]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_JakaMena] CHECK  (([AutoUPOMPF_JakaMena]=(1) OR [AutoUPOMPF_JakaMena]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_JakaMena]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_PenalOd] CHECK  (([AutoUPOMPF_PenalOd]=(1) OR [AutoUPOMPF_PenalOd]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_PenalOd]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_PenalOdCastka] CHECK  (([AutoUPOMPF_PenalOdCastka]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_PenalOdCastka]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_PenalPo] CHECK  (([AutoUPOMPF_PenalPo]=(1) OR [AutoUPOMPF_PenalPo]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_PenalPo]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_PenalPoDnu] CHECK  (([AutoUPOMPF_PenalPoDnu]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_PenalPoDnu]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomDoDnu] CHECK  (([AutoUPOMPF_UpomDoDnu]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomDoDnu]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomOd] CHECK  (([AutoUPOMPF_UpomOd]=(1) OR [AutoUPOMPF_UpomOd]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomOd]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomOdCastka] CHECK  (([AutoUPOMPF_UpomOdCastka]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomOdCastka]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomPo] CHECK  (([AutoUPOMPF_UpomPo]=(3) OR [AutoUPOMPF_UpomPo]=(2) OR [AutoUPOMPF_UpomPo]=(1) OR [AutoUPOMPF_UpomPo]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomPo]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomPoDnu] CHECK  (([AutoUPOMPF_UpomPoDnu]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AutoUPOMPF_UpomPoDnu]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__AVAOutputFlag] CHECK  (([AVAOutputFlag]=(5) OR [AVAOutputFlag]=(4) OR [AVAOutputFlag]=(3) OR [AVAOutputFlag]=(2) OR [AVAOutputFlag]=(1) OR [AVAOutputFlag]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__AVAOutputFlag]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__CisloOrg] CHECK  (([CisloOrg]>=(0) AND [CisloOrg]<=(999999999)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__CisloOrg]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__KorekceSplatnoAuto] CHECK  (([KorekceSplatnoAuto]>=(-50000) AND [KorekceSplatnoAuto]<=(50000)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__KorekceSplatnoAuto]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__KorekceSplatnoUziv] CHECK  (([KorekceSplatnoUziv]>=(-50000) AND [KorekceSplatnoUziv]<=(50000)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__KorekceSplatnoUziv]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__KorekceSplatnoUzivD] CHECK  (([KorekceSplatnoUzivD]>=(-50000) AND [KorekceSplatnoUzivD]<=(50000)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__KorekceSplatnoUzivD]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__Legislativa] CHECK  (([Legislativa]>=(0) AND [Legislativa]<=(1)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__Legislativa]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__LhutaSplatnosti] CHECK  (([LhutaSplatnosti]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__LhutaSplatnosti]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__LhutaSplatnostiDodavatel] CHECK  (([LhutaSplatnostiDodavatel]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__LhutaSplatnostiDodavatel]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__NadrizenaOrg] CHECK  (([NadrizenaOrg]<>[CisloOrg]))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__NadrizenaOrg]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__NastavDatSplatPocOdFP] CHECK  (([NastavDatSplatPocOdFP]=(100) OR [NastavDatSplatPocOdFP]=(9) OR [NastavDatSplatPocOdFP]=(8) OR [NastavDatSplatPocOdFP]=(7) OR [NastavDatSplatPocOdFP]=(6) OR [NastavDatSplatPocOdFP]=(5) OR [NastavDatSplatPocOdFP]=(4) OR [NastavDatSplatPocOdFP]=(3) OR [NastavDatSplatPocOdFP]=(2) OR [NastavDatSplatPocOdFP]=(1) OR [NastavDatSplatPocOdFP]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__NastavDatSplatPocOdFP]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__NastavDatSplatPocOdFV] CHECK  (([NastavDatSplatPocOdFV]=(100) OR [NastavDatSplatPocOdFV]=(9) OR [NastavDatSplatPocOdFV]=(6) OR [NastavDatSplatPocOdFV]=(5) OR [NastavDatSplatPocOdFV]=(4) OR [NastavDatSplatPocOdFV]=(3) OR [NastavDatSplatPocOdFV]=(2) OR [NastavDatSplatPocOdFV]=(1) OR [NastavDatSplatPocOdFV]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__NastavDatSplatPocOdFV]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__NespolehPlatce] CHECK  (([NespolehPlatce]>=(0) AND [NespolehPlatce]<=(3)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__NespolehPlatce]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__OdHodnoty] CHECK  (([OdHodnoty]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__OdHodnoty]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__Penale] CHECK  (([Penale]=(3) OR [Penale]=(2) OR [Penale]=(1) OR [Penale]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__Penale]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__PocetZam] CHECK  (([PocetZam]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__PocetZam]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__PravniForma] CHECK  (([PravniForma]>=(0) AND [PravniForma]<=(3)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__PravniForma]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__PZ2PoradiVstup] CHECK  (([PZ2PoradiVstup]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__PZ2PoradiVstup]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__PZ2PoradiVystup] CHECK  (([PZ2PoradiVystup]>=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__PZ2PoradiVystup]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__RezimPenalizace] CHECK  (([RezimPenalizace]=(3) OR [RezimPenalizace]=(2) OR [RezimPenalizace]=(1) OR [RezimPenalizace]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__RezimPenalizace]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__SlevaKmenZbo] CHECK  (([SlevaKmenZbo]=(2) OR [SlevaKmenZbo]=(1) OR [SlevaKmenZbo]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__SlevaKmenZbo]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__SlevaOrg] CHECK  (([SlevaOrg]=(2) OR [SlevaOrg]=(1) OR [SlevaOrg]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__SlevaOrg]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__SlevaSkupZbo] CHECK  (([SlevaSkupZbo]=(2) OR [SlevaSkupZbo]=(1) OR [SlevaSkupZbo]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__SlevaSkupZbo]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__SlevaSozNa] CHECK  (([SlevaSozNa]=(2) OR [SlevaSozNa]=(1) OR [SlevaSozNa]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__SlevaSozNa]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__SlevaStavSkladu] CHECK  (([SlevaStavSkladu]=(2) OR [SlevaStavSkladu]=(1) OR [SlevaStavSkladu]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__SlevaStavSkladu]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__SlevaZbozi] CHECK  (([SlevaZbozi]=(2) OR [SlevaZbozi]=(1) OR [SlevaZbozi]=(0)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__SlevaZbozi]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__VstupniCenaDod] CHECK  (([VstupniCenaDod]>=(0) AND [VstupniCenaDod]<=(11) OR [VstupniCenaDod]=(100)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__VstupniCenaDod]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__VstupniCenaOdb] CHECK  (([VstupniCenaOdb]>=(0) AND [VstupniCenaOdb]<=(11) OR [VstupniCenaOdb]=(100)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__VstupniCenaOdb]
GO

ALTER TABLE [dbo].[TabCisOrg]  WITH CHECK ADD  CONSTRAINT [CK__TabCisOrg__ZajisteniDPHJinyDuvodRuceni] CHECK  (([ZajisteniDPHJinyDuvodRuceni]>=(0) AND [ZajisteniDPHJinyDuvodRuceni]<=(6)))
GO

ALTER TABLE [dbo].[TabCisOrg] CHECK CONSTRAINT [CK__TabCisOrg__ZajisteniDPHJinyDuvodRuceni]
GO

