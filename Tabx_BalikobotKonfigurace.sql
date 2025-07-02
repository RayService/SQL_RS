USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotKonfigurace]    Script Date: 02.07.2025 8:29:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotKonfigurace](
	[Vychozi] [bit] NOT NULL,
	[API_Login] [nvarchar](100) NULL,
	[API_Key] [nvarchar](100) NULL,
	[DatAktualizaceCiselniku] [datetime] NULL,
	[PovolitNerealizovane] [bit] NOT NULL,
	[PovolitZmenuVazby] [bit] NOT NULL,
	[NekontrolovatPSC] [bit] NOT NULL,
	[ExpedicniMisto] [nvarchar](50) NULL,
	[ZpusobDohledaniKontaktu] [tinyint] NOT NULL,
	[GenerovatVychoziHmotnost] [bit] NOT NULL,
	[NeprovadetValidaci] [bit] NOT NULL,
	[TiskPoZaevidovani] [bit] NOT NULL,
	[TiskPoZaevidovaniCmd] [nvarchar](255) NULL,
	[TiskPoZaevidovaniCmdPar] [nvarchar](255) NULL,
	[ZaviratProcesOkno] [bit] NOT NULL,
	[ZaviratProcesOknoVZDY] [bit] NOT NULL,
	[NezobrazovatPotvrzeni] [bit] NOT NULL,
	[ZaevidujPoGenerovani] [bit] NOT NULL,
	[AktualizaceBezDotazu] [bit] NOT NULL,
	[RealOrderIdTyp] [tinyint] NOT NULL,
	[LogAPI_Uroven] [tinyint] NOT NULL,
	[IntervalMazani] [tinyint] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_BalikobotKonfigurace__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__Vychozi]  DEFAULT ((0)) FOR [Vychozi]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__PovolitNerealizovane]  DEFAULT ((0)) FOR [PovolitNerealizovane]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__PovolitZmenuVazby]  DEFAULT ((0)) FOR [PovolitZmenuVazby]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__NekontrolovatPSC]  DEFAULT ((0)) FOR [NekontrolovatPSC]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__ZpusobDohledaniKontaktu]  DEFAULT ((1)) FOR [ZpusobDohledaniKontaktu]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__GenerovatVychoziHmotnost]  DEFAULT ((0)) FOR [GenerovatVychoziHmotnost]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__NeprovadetValidaci]  DEFAULT ((1)) FOR [NeprovadetValidaci]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__TiskPoZaevidovani]  DEFAULT ((0)) FOR [TiskPoZaevidovani]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__ZaviratProcesOkno]  DEFAULT ((0)) FOR [ZaviratProcesOkno]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__ZaviratProcesOknoVZDY]  DEFAULT ((0)) FOR [ZaviratProcesOknoVZDY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__NezobrazovatPotvrzeni]  DEFAULT ((0)) FOR [NezobrazovatPotvrzeni]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__ZaevidujPoGenerovani]  DEFAULT ((0)) FOR [ZaevidujPoGenerovani]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__AktualizaceBezDotazu]  DEFAULT ((0)) FOR [AktualizaceBezDotazu]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__RealOrderIdTyp]  DEFAULT ((0)) FOR [RealOrderIdTyp]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__LogAPI_Uroven]  DEFAULT ((0)) FOR [LogAPI_Uroven]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__IntervalMazani]  DEFAULT ((2)) FOR [IntervalMazani]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] ADD  CONSTRAINT [DF__Tabx_BalikobotKonfigurace__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_BalikobotKonfigurace__IntervalMazani] CHECK  (([IntervalMazani]>=(0) AND [IntervalMazani]<=(24)))
GO

ALTER TABLE [dbo].[Tabx_BalikobotKonfigurace] CHECK CONSTRAINT [CK__Tabx_BalikobotKonfigurace__IntervalMazani]
GO

