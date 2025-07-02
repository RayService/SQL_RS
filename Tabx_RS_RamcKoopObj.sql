USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_RamcKoopObj]    Script Date: 02.07.2025 9:42:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_RamcKoopObj](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Rada] [int] NOT NULL,
	[Cislo] [int] NOT NULL,
	[IDOrganizace] [int] NULL,
	[TerminOdeslani] [datetime] NOT NULL,
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
	[Realizovano] [bit] NOT NULL,
	[DatRealizace] [datetime] NULL,
	[DatRealizace_D]  AS (datepart(day,[DatRealizace])),
	[DatRealizace_M]  AS (datepart(month,[DatRealizace])),
	[DatRealizace_Y]  AS (datepart(year,[DatRealizace])),
	[DatRealizace_Q]  AS (datepart(quarter,[DatRealizace])),
	[DatRealizace_W]  AS (datepart(week,[DatRealizace])),
	[DatRealizace_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatRealizace])))),
	[PolSplneny] [bit] NOT NULL,
	[Uzavreno] [bit] NOT NULL,
	[AutorUzavreni] [nvarchar](128) NULL,
	[CenaPrepravy] [numeric](19, 6) NOT NULL,
	[DobaPrepravy] [numeric](19, 6) NOT NULL,
	[DobaPrepravy_T] [tinyint] NOT NULL,
	[PocetPrepravDavek] [numeric](19, 6) NOT NULL,
	[CenaPolozek] [numeric](19, 6) NOT NULL,
	[Poznamka] [nvarchar](max) NULL,
	[FormaUhrady] [nvarchar](30) NULL,
	[FormaDopravy] [nvarchar](30) NULL,
	[IDZamestnance] [int] NULL,
	[IDKOsoby] [int] NULL,
	[Splneno]  AS (CONVERT([bit],case when [PolSplneny]=(1) OR [uzavreno]=(1) then (1) else (0) end,(0))),
	[CenaCelkem]  AS (CONVERT([numeric](19,6),[CenaPolozek]+[CenaPrepravy],(0))),
	[DatumUzavreni] [datetime] NULL,
	[IDMistoUrceni] [int] NULL,
	[DobaPrepravy_S]  AS (CONVERT([numeric](19,6),[DobaPrepravy]*case [DobaPrepravy_T] when (0) then (1.0) when (1) then (60.0) when (2) then (3600.0) when (3) then (86400.0)  end,(0))),
	[DobaPrepravy_N]  AS (CONVERT([numeric](19,6),case [DobaPrepravy_T] when (0) then [DobaPrepravy]/(60.0) when (1) then [DobaPrepravy] when (2) then (60.0)*[DobaPrepravy] when (3) then (1440.0)*[DobaPrepravy]  end,(0))),
	[DobaPrepravy_H]  AS (CONVERT([numeric](19,6),case [DobaPrepravy_T] when (0) then [DobaPrepravy]/(3600.0) when (1) then [DobaPrepravy]/(60.0) when (2) then [DobaPrepravy] when (3) then (24.0)*[DobaPrepravy]  end,(0))),
	[DobaPrepravy_D]  AS (CONVERT([numeric](19,6),[DobaPrepravy]/case [DobaPrepravy_T] when (0) then (86400.0) when (1) then (1440.0) when (2) then (24.0) when (3) then (1.0)  end,(0))),
	[CenaPrepravyHM] [numeric](19, 6) NOT NULL,
	[CenaPolozekHM] [numeric](19, 6) NOT NULL,
	[Mena] [nvarchar](3) NULL,
	[DatumKurzu] [datetime] NULL,
	[Kurz] [numeric](19, 6) NOT NULL,
	[JednotkaMeny] [int] NOT NULL,
	[VstupniCena] [tinyint] NOT NULL,
	[CenaCelkemHM]  AS (CONVERT([numeric](19,6),[CenaPolozekHM]+[CenaPrepravyHM])),
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
	[TerminOdeslani_D]  AS (datepart(day,[TerminOdeslani])),
	[TerminOdeslani_M]  AS (datepart(month,[TerminOdeslani])),
	[TerminOdeslani_Y]  AS (datepart(year,[TerminOdeslani])),
	[TerminOdeslani_Q]  AS (datepart(quarter,[TerminOdeslani])),
	[TerminOdeslani_W]  AS (datepart(week,[TerminOdeslani])),
	[TerminOdeslani_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[TerminOdeslani])))),
	[Objednavka]  AS (CONVERT([nvarchar](20),((rtrim([Rada])+N'/')+isnull(replicate(N'0',(6)-len([Cislo])),''))+CONVERT([nvarchar](10),[Cislo],(0)),(0))),
 CONSTRAINT [PK__Tabx_RS_RamcKoopObj__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__Rada]  DEFAULT ((1)) FOR [Rada]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__Cislo]  DEFAULT ((1)) FOR [Cislo]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__TerminOdeslani]  DEFAULT (getdate()) FOR [TerminOdeslani]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__Realizovano]  DEFAULT ((0)) FOR [Realizovano]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__PolSplneny]  DEFAULT ((0)) FOR [PolSplneny]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__Uzavreno]  DEFAULT ((0)) FOR [Uzavreno]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__CenaPrepravy]  DEFAULT ((0)) FOR [CenaPrepravy]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__DobaPrepravy]  DEFAULT ((0)) FOR [DobaPrepravy]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__DobaPrepravy_T]  DEFAULT ((2)) FOR [DobaPrepravy_T]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__PocetPrepravDavek]  DEFAULT ((1)) FOR [PocetPrepravDavek]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__CenaPolozek]  DEFAULT ((0)) FOR [CenaPolozek]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__CenaPrepravyHM]  DEFAULT ((0)) FOR [CenaPrepravyHM]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__CenaPolozekHM]  DEFAULT ((0)) FOR [CenaPolozekHM]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__Kurz]  DEFAULT ((1)) FOR [Kurz]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__JednotkaMeny]  DEFAULT ((1)) FOR [JednotkaMeny]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__VstupniCena]  DEFAULT ((0)) FOR [VstupniCena]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] ADD  CONSTRAINT [DF__Tabx_RS_RamcKoopObj__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_RamcKoopObj__FormaDopravy] FOREIGN KEY([FormaDopravy])
REFERENCES [dbo].[TabFormaDopravy] ([FormaDopravy])
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_RamcKoopObj__FormaDopravy]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_RamcKoopObj__FormaUhrady] FOREIGN KEY([FormaUhrady])
REFERENCES [dbo].[TabFormaUhrady] ([FormaUhrady])
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_RamcKoopObj__FormaUhrady]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_RamcKoopObj__IDKOsoby] FOREIGN KEY([IDKOsoby])
REFERENCES [dbo].[TabCisKOs] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_RamcKoopObj__IDKOsoby]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_RamcKoopObj__IDMistoUrceni] FOREIGN KEY([IDMistoUrceni])
REFERENCES [dbo].[TabCisOrg] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_RamcKoopObj__IDMistoUrceni]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_RamcKoopObj__IDOrganizace] FOREIGN KEY([IDOrganizace])
REFERENCES [dbo].[TabCisOrg] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_RamcKoopObj__IDOrganizace]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_RamcKoopObj__IDZamestnance] FOREIGN KEY([IDZamestnance])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_RamcKoopObj__IDZamestnance]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_RamcKoopObj__Mena] FOREIGN KEY([Mena])
REFERENCES [dbo].[TabKodMen] ([Kod])
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [FK__Tabx_RS_RamcKoopObj__Mena]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_RamcKoopObj__Cislo] CHECK  (([Cislo]>(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_RamcKoopObj__Cislo]
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_RamcKoopObj__DobaPrepravy_T] CHECK  (([DobaPrepravy_T]>=(0) AND [DobaPrepravy_T]<=(3)))
GO

ALTER TABLE [dbo].[Tabx_RS_RamcKoopObj] CHECK CONSTRAINT [CK__Tabx_RS_RamcKoopObj__DobaPrepravy_T]
GO

