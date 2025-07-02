USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING]    Script Date: 02.07.2025 9:24:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Cislo_VP] [nvarchar](30) NOT NULL,
	[ID_Vyrobku] [nvarchar](20) NOT NULL,
	[Obj_Mnozstvi] [numeric](19, 6) NULL,
	[PST] [datetime] NULL,
	[PET] [datetime] NULL,
	[PET_D]  AS (datepart(day,[PET])),
	[PET_M]  AS (datepart(month,[PET])),
	[PET_Y]  AS (datepart(year,[PET])),
	[PET_Q]  AS (datepart(quarter,[PET])),
	[PET_W]  AS (datepart(week,[PET])),
	[PET_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[PET])))),
	[PST_D]  AS (datepart(day,[PST])),
	[PST_M]  AS (datepart(month,[PST])),
	[PST_Y]  AS (datepart(year,[PST])),
	[PST_Q]  AS (datepart(quarter,[PST])),
	[PST_W]  AS (datepart(week,[PST])),
	[PST_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[PST])))),
	[LPST] [datetime] NULL,
	[LPST_D]  AS (datepart(day,[LPST])),
	[LPST_M]  AS (datepart(month,[LPST])),
	[LPST_Y]  AS (datepart(year,[LPST])),
	[LPST_Q]  AS (datepart(quarter,[LPST])),
	[LPST_W]  AS (datepart(week,[LPST])),
	[LPST_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[LPST])))),
	[EPST] [datetime] NULL,
	[EPST_D]  AS (datepart(day,[EPST])),
	[EPST_M]  AS (datepart(month,[EPST])),
	[EPST_Y]  AS (datepart(year,[EPST])),
	[EPST_Q]  AS (datepart(quarter,[EPST])),
	[EPST_W]  AS (datepart(week,[EPST])),
	[EPST_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[EPST])))),
	[ID_Zakazek] [nvarchar](4000) NULL,
	[ID_Zakazky] [nvarchar](30) NULL,
	[Rada_VP] [nvarchar](100) NULL,
	[Pokryto] [bit] NULL,
	[Typ_Dodavky] [nvarchar](100) NULL,
	[ID_Dodavky] [nvarchar](300) NULL,
	[ID_Materialu] [nvarchar](100) NULL,
	[Alokovano] [numeric](19, 6) NULL,
	[Doporuceni] [nvarchar](255) NULL,
	[Zpozdeni] [numeric](19, 6) NULL,
	[T_Dodani] [datetime] NULL,
	[T_Dodani_D]  AS (datepart(day,[T_Dodani])),
	[T_Dodani_M]  AS (datepart(month,[T_Dodani])),
	[T_Dodani_Y]  AS (datepart(year,[T_Dodani])),
	[T_Dodani_Q]  AS (datepart(quarter,[T_Dodani])),
	[T_Dodani_W]  AS (datepart(week,[T_Dodani])),
	[T_Dodani_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[T_Dodani])))),
	[T_Potreby] [datetime] NULL,
	[T_Potreby_D]  AS (datepart(day,[T_Potreby])),
	[T_Potreby_M]  AS (datepart(month,[T_Potreby])),
	[T_Potreby_Y]  AS (datepart(year,[T_Potreby])),
	[T_Potreby_Q]  AS (datepart(quarter,[T_Potreby])),
	[T_Potreby_W]  AS (datepart(week,[T_Potreby])),
	[T_Potreby_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[T_Potreby])))),
	[Mn_Objednane] [numeric](19, 6) NULL,
	[Mn_Nevyuzite] [numeric](19, 6) NULL,
	[Suma_Potreb] [numeric](19, 6) NULL,
	[Suma_NO] [numeric](19, 6) NULL,
	[Suma_NNO] [numeric](19, 6) NULL,
	[T_PotrebyPP] [datetime] NULL,
	[T_PotrebyPP_D]  AS (datepart(day,[T_PotrebyPP])),
	[T_PotrebyPP_M]  AS (datepart(month,[T_PotrebyPP])),
	[T_PotrebyPP_Y]  AS (datepart(year,[T_PotrebyPP])),
	[T_PotrebyPP_Q]  AS (datepart(quarter,[T_PotrebyPP])),
	[T_PotrebyPP_W]  AS (datepart(week,[T_PotrebyPP])),
	[T_PotrebyPP_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[T_PotrebyPP])))),
	[Mn_ObjednanePP] [numeric](19, 6) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[T_VystaveniPP] [datetime] NULL,
	[T_VystaveniPP_D]  AS (datepart(day,[T_VystaveniPP])),
	[T_VystaveniPP_M]  AS (datepart(month,[T_VystaveniPP])),
	[T_VystaveniPP_Y]  AS (datepart(year,[T_VystaveniPP])),
	[T_VystaveniPP_Q]  AS (datepart(quarter,[T_VystaveniPP])),
	[T_VystaveniPP_W]  AS (datepart(week,[T_VystaveniPP])),
	[T_VystaveniPP_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[T_VystaveniPP])))),
	[Mn_Objednane_New] [numeric](19, 6) NULL,
	[T_Dodani_New] [datetime] NULL,
	[T_Dodani_New_D]  AS (datepart(day,[T_Dodani_New])),
	[T_Dodani_New_M]  AS (datepart(month,[T_Dodani_New])),
	[T_Dodani_New_Y]  AS (datepart(year,[T_Dodani_New])),
	[T_Dodani_New_Q]  AS (datepart(quarter,[T_Dodani_New])),
	[T_Dodani_New_W]  AS (datepart(week,[T_Dodani_New])),
	[T_Dodani_New_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[T_Dodani_New])))),
	[Status] [nvarchar](100) NULL,
	[Potvrzeny_TDOD] [bit] NULL,
	[T_Nejdrive_Mozny] [datetime] NULL,
	[T_Nejdrive_Mozny_D]  AS (datepart(day,[T_Nejdrive_Mozny])),
	[T_Nejdrive_Mozny_M]  AS (datepart(month,[T_Nejdrive_Mozny])),
	[T_Nejdrive_Mozny_Y]  AS (datepart(year,[T_Nejdrive_Mozny])),
	[T_Nejdrive_Mozny_Q]  AS (datepart(quarter,[T_Nejdrive_Mozny])),
	[T_Nejdrive_Mozny_W]  AS (datepart(week,[T_Nejdrive_Mozny])),
	[T_Nejdrive_Mozny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[T_Nejdrive_Mozny])))),
	[DokonceniProcesDilce] [datetime] NULL,
	[DokonceniProcesDilce_D]  AS (datepart(day,[DokonceniProcesDilce])),
	[DokonceniProcesDilce_M]  AS (datepart(month,[DokonceniProcesDilce])),
	[DokonceniProcesDilce_Y]  AS (datepart(year,[DokonceniProcesDilce])),
	[DokonceniProcesDilce_Q]  AS (datepart(quarter,[DokonceniProcesDilce])),
	[DokonceniProcesDilce_W]  AS (datepart(week,[DokonceniProcesDilce])),
	[DokonceniProcesDilce_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DokonceniProcesDilce])))),
	[RAY_IM_InitialStock] [numeric](19, 6) NULL,
	[RAY_IM_FinalStock] [numeric](19, 6) NULL,
	[IDPohyb_VOB] [int] NULL,
	[ID_VOB] [int] NULL,
	[ZpozdeniMaterialu]  AS (datediff(day,[LPST],[T_Dodani_New])),
	[Vcasnost] [int] NULL,
	[Pricina_vcasnosti] [nvarchar](1000) NULL,
	[ID_NadrizenychZakazek] [nvarchar](4000) NULL,
 CONSTRAINT [PK__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Obj_Mnozstvi]  DEFAULT ((0)) FOR [Obj_Mnozstvi]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Alokovano]  DEFAULT ((0)) FOR [Alokovano]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Mn_Objednane]  DEFAULT ((0)) FOR [Mn_Objednane]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Mn_Nevyuzite]  DEFAULT ((0)) FOR [Mn_Nevyuzite]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Suma_Potreb]  DEFAULT ((0)) FOR [Suma_Potreb]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Suma_NO]  DEFAULT ((0)) FOR [Suma_NO]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Suma_NNO]  DEFAULT ((0)) FOR [Suma_NNO]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Mn_ObjednanePP]  DEFAULT ((0)) FOR [Mn_ObjednanePP]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Mn_Objednane_New]  DEFAULT ((0)) FOR [Mn_Objednane_New]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__Potvrzeny_TDOD]  DEFAULT ((0)) FOR [Potvrzeny_TDOD]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__RAY_IM_InitialStock]  DEFAULT ((0)) FOR [RAY_IM_InitialStock]
GO

ALTER TABLE [dbo].[Tabx_RS_OUT_MANUFACTURINGORDERJAGGING] ADD  CONSTRAINT [DF__Tabx_RS_OUT_MANUFACTURINGORDERJAGGING__RAY_IM_FinalStock]  DEFAULT ((0)) FOR [RAY_IM_FinalStock]
GO

