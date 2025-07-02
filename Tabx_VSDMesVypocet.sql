USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VSDMesVypocet]    Script Date: 02.07.2025 10:37:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VSDMesVypocet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdVSDVyuct] [int] NOT NULL,
	[mesic] [smallint] NOT NULL,
	[cj_dpsi07] [nvarchar](30) NOT NULL,
	[kc_dpsi01_kor] [numeric](19, 6) NOT NULL,
	[kc_dpsi01_vyp] [numeric](19, 6) NOT NULL,
	[kc_dpsi02_kor] [numeric](19, 6) NOT NULL,
	[kc_dpsi02_vyp] [numeric](19, 6) NOT NULL,
	[kc_dpsi03] [numeric](19, 6) NOT NULL,
	[kc_dpsi04] [numeric](19, 6) NULL,
	[kc_dpsi05] [numeric](19, 6) NULL,
	[kc_dpsi06] [numeric](19, 6) NOT NULL,
	[kc_dpsi07] [numeric](19, 6) NOT NULL,
	[kc_dpsi09] [numeric](19, 6) NOT NULL,
	[kc_dpsi10_kor] [numeric](19, 6) NOT NULL,
	[kc_dpsi10_vyp] [numeric](19, 6) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[kc_dpsi01]  AS (CONVERT([numeric](19,6),[kc_dpsi01_vyp]+[kc_dpsi01_kor])),
	[kc_dpsi02]  AS (CONVERT([numeric](19,6),[kc_dpsi02_vyp]+[kc_dpsi02_kor])),
	[kc_dpsi08]  AS (CONVERT([numeric](19,6),[kc_dpsi05]-[kc_dpsi04])),
	[kc_dpsi08a]  AS (CONVERT([numeric](19,6),([kc_dpsi01_vyp]+[kc_dpsi01_kor])-[kc_dpsi07])),
	[kc_dpsi10]  AS (CONVERT([numeric](19,6),[kc_dpsi10_vyp]+[kc_dpsi10_kor])),
 CONSTRAINT [PK__Tabx_VSDMesVypocet__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__cj_dpsi07]  DEFAULT ('') FOR [cj_dpsi07]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi01_kor]  DEFAULT ((0.0)) FOR [kc_dpsi01_kor]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi01_vyp]  DEFAULT ((0.0)) FOR [kc_dpsi01_vyp]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi02_kor]  DEFAULT ((0.0)) FOR [kc_dpsi02_kor]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi02_vyp]  DEFAULT ((0.0)) FOR [kc_dpsi02_vyp]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi03]  DEFAULT ((0.0)) FOR [kc_dpsi03]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi06]  DEFAULT ((0.0)) FOR [kc_dpsi06]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi07]  DEFAULT ((0.0)) FOR [kc_dpsi07]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi09]  DEFAULT ((0.0)) FOR [kc_dpsi09]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi10_kor]  DEFAULT ((0.0)) FOR [kc_dpsi10_kor]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__kc_dpsi10_vyp]  DEFAULT ((0.0)) FOR [kc_dpsi10_vyp]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VSDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VSDMesVypocet__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

