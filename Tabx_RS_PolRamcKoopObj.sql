USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PolRamcKoopObj]    Script Date: 02.07.2025 9:37:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PolRamcKoopObj](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Uzavreno] [bit] NOT NULL,
	[AutorUzavreni] [nvarchar](128) NULL,
	[IDObjednavky] [int] NULL,
	[Polozka] [int] NOT NULL,
	[IDkooperace] [int] NULL,
	[Kusy] [numeric](19, 6) NOT NULL,
	[KoopMnozstvi] [numeric](19, 6) NOT NULL,
	[KusyPrevedene] [numeric](19, 6) NOT NULL,
	[Cena] [numeric](19, 6) NOT NULL,
	[PocetPrepravDavek] [numeric](19, 6) NOT NULL,
	[Poznamka] [nvarchar](max) NULL,
	[PozadTerDod] [datetime] NULL,
	[PozadTerDod_D]  AS (datepart(day,[PozadTerDod])),
	[PozadTerDod_M]  AS (datepart(month,[PozadTerDod])),
	[PozadTerDod_Y]  AS (datepart(year,[PozadTerDod])),
	[PozadTerDod_Q]  AS (datepart(quarter,[PozadTerDod])),
	[PozadTerDod_W]  AS (datepart(week,[PozadTerDod])),
	[PozadTerDod_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[PozadTerDod])))),
	[PotvrzTerDod] [datetime] NULL,
	[PotvrzTerDod_D]  AS (datepart(day,[PotvrzTerDod])),
	[PotvrzTerDod_M]  AS (datepart(month,[PotvrzTerDod])),
	[PotvrzTerDod_Y]  AS (datepart(year,[PotvrzTerDod])),
	[PotvrzTerDod_Q]  AS (datepart(quarter,[PotvrzTerDod])),
	[PotvrzTerDod_W]  AS (datepart(week,[PotvrzTerDod])),
	[PotvrzTerDod_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[PotvrzTerDod])))),
	[Splneno]  AS (CONVERT([bit],case when [KusyPrevedene]>=[kusy] OR [uzavreno]=(1) then (1) else (0) end,(0))),
	[CelkKoopMnozstvi]  AS (CONVERT([numeric](19,6),[Kusy]*[KoopMnozstvi],(0))),
	[KusyVKoop]  AS (CONVERT([numeric](19,6),case when [uzavreno]=(1) OR [KusyPrevedene]>=[kusy] then (0.0) else [kusy]-[KusyPrevedene] end,(0))),
	[DatumUzavreni] [datetime] NULL,
	[DatumUzavreni_D]  AS (datepart(day,[DatumUzavreni])),
	[DatumUzavreni_M]  AS (datepart(month,[DatumUzavreni])),
	[DatumUzavreni_Y]  AS (datepart(year,[DatumUzavreni])),
	[DatumUzavreni_Q]  AS (datepart(quarter,[DatumUzavreni])),
	[DatumUzavreni_W]  AS (datepart(week,[DatumUzavreni])),
	[DatumUzavreni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumUzavreni])))),
	[JCena] [numeric](19, 6) NOT NULL,
	[JCenaHM] [numeric](19, 6) NOT NULL,
	[CenaHM] [numeric](19, 6) NOT NULL,
	[Mena] [nvarchar](3) NULL,
	[DatumKurzu] [datetime] NULL,
	[DatumKurzu_D]  AS (datepart(day,[DatumKurzu])),
	[DatumKurzu_M]  AS (datepart(month,[DatumKurzu])),
	[DatumKurzu_Y]  AS (datepart(year,[DatumKurzu])),
	[DatumKurzu_Q]  AS (datepart(quarter,[DatumKurzu])),
	[DatumKurzu_W]  AS (datepart(week,[DatumKurzu])),
	[DatumKurzu_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumKurzu])))),
	[Kurz] [numeric](19, 6) NOT NULL,
	[JednotkaMeny] [int] NOT NULL,
	[VstupniCena] [tinyint] NOT NULL,
	[BarCode]  AS (CONVERT([nvarchar](15),((N'B1.'+isnull(replicate(N'0',(2)-len([ID])),''))+CONVERT([nvarchar](13),[ID]))+N'B')),
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny])))),
	[Takt] [int] NOT NULL,
	[TypTaktu] [int] NOT NULL,
	[PocetTaktu]  AS ([Kusy]/isnull([Takt],(1))),
	[PocetTaktuVKoop]  AS (CONVERT([numeric](19,6),case when [uzavreno]=(1) OR [KusyPrevedene]>=[kusy] then (0.0) else [kusy]-[KusyPrevedene] end,(0))/isnull([Takt],(1))),
 CONSTRAINT [PK__Tabx_RS_PolRamcKoopObj__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__Uzavreno]  DEFAULT ((0)) FOR [Uzavreno]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__Polozka]  DEFAULT ((1)) FOR [Polozka]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__Kusy]  DEFAULT ((0)) FOR [Kusy]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__KoopMnozstvi]  DEFAULT ((0)) FOR [KoopMnozstvi]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__KusyPrevedene]  DEFAULT ((0)) FOR [KusyPrevedene]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__Cena]  DEFAULT ((0)) FOR [Cena]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__PocetPrepravDavek]  DEFAULT ((0)) FOR [PocetPrepravDavek]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__JCena]  DEFAULT ((0)) FOR [JCena]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__JCenaHM]  DEFAULT ((0)) FOR [JCenaHM]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__CenaHM]  DEFAULT ((0)) FOR [CenaHM]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__Kurz]  DEFAULT ((1)) FOR [Kurz]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__JednotkaMeny]  DEFAULT ((1)) FOR [JednotkaMeny]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__VstupniCena]  DEFAULT ((0)) FOR [VstupniCena]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__Takt]  DEFAULT ((0)) FOR [Takt]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_PolRamcKoopObj__TypTaktu]  DEFAULT ((1)) FOR [TypTaktu]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_PolRamcKoopObj__IDkooperace] FOREIGN KEY([IDkooperace])
REFERENCES [dbo].[TabCKoop] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_PolRamcKoopObj__IDkooperace]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_PolRamcKoopObj__IDObjednavky] FOREIGN KEY([IDObjednavky])
REFERENCES [dbo].[Tabx_RS_RamcKoopObj] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_PolRamcKoopObj__IDObjednavky]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__Cena] CHECK  (([Cena]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__Cena]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__CenaHM] CHECK  (([CenaHM]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__CenaHM]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__JCena] CHECK  (([JCena]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__JCena]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__JCenaHM] CHECK  (([JCenaHM]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__JCenaHM]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__JednotkaMeny] CHECK  (([JednotkaMeny]>(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__JednotkaMeny]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__Kurz] CHECK  (([Kurz]>(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__Kurz]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__KusyPrevedene] CHECK  (([KusyPrevedene]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__KusyPrevedene]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__PocetPrepravDavek] CHECK  (([PocetPrepravDavek]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__PocetPrepravDavek]
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__Polozka] CHECK  (([Polozka]>(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_PolRamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_PolRamcKoopObj__Polozka]
GO

