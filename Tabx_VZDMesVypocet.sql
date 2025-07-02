USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDMesVypocet]    Script Date: 02.07.2025 10:40:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDMesVypocet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdVZDVDA] [int] NOT NULL,
	[mesic] [smallint] NOT NULL,
	[cj_dpzi03] [nvarchar](30) NOT NULL,
	[kc_dpzi03a] [numeric](19, 6) NOT NULL,
	[kc_dpzi01_kor] [numeric](19, 6) NOT NULL,
	[kc_dpzi01_vyp] [numeric](19, 6) NOT NULL,
	[kc_dpzi02_kor] [numeric](19, 6) NOT NULL,
	[kc_dpzi02_vyp] [numeric](19, 6) NOT NULL,
	[kc_dpzi04_kor] [numeric](19, 6) NOT NULL,
	[kc_dpzi04_vyp] [numeric](19, 6) NOT NULL,
	[kc_dpzi05_kor] [numeric](19, 6) NOT NULL,
	[kc_dpzi05_vyp] [numeric](19, 6) NOT NULL,
	[kc_dpzi06_kor] [numeric](19, 6) NOT NULL,
	[kc_dpzi06_vyp] [numeric](19, 6) NOT NULL,
	[kc_dpzi07_kor] [numeric](19, 6) NOT NULL,
	[kc_dpzi07_vyp] [numeric](19, 6) NOT NULL,
	[kc_dpzi10] [numeric](19, 6) NOT NULL,
	[kc_dpzi11_kor] [numeric](19, 6) NOT NULL,
	[kc_dpzi11_vyp] [numeric](19, 6) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[kc_dpzi01]  AS (CONVERT([numeric](19,6),[kc_dpzi01_vyp]+[kc_dpzi01_kor])),
	[kc_dpzi02]  AS (CONVERT([numeric](19,6),[kc_dpzi02_vyp]+[kc_dpzi02_kor])),
	[kc_dpzi04]  AS (CONVERT([numeric](19,6),[kc_dpzi04_vyp]+[kc_dpzi04_kor])),
	[kc_dpzi05]  AS (CONVERT([numeric](19,6),[kc_dpzi05_vyp]+[kc_dpzi05_kor])),
	[kc_dpzi06]  AS (CONVERT([numeric](19,6),[kc_dpzi06_vyp]+[kc_dpzi06_kor])),
	[kc_dpzi07]  AS (CONVERT([numeric](19,6),[kc_dpzi07_vyp]+[kc_dpzi07_kor])),
	[kc_dpzi08]  AS (CONVERT([numeric](19,6),((([kc_dpzi04_vyp]+[kc_dpzi04_kor])+([kc_dpzi05_vyp]+[kc_dpzi05_kor]))+([kc_dpzi06_vyp]+[kc_dpzi06_kor]))-([kc_dpzi07_vyp]+[kc_dpzi07_kor]))),
	[kc_dpzi09]  AS (CONVERT([numeric](19,6),((([kc_dpzi01_vyp]+[kc_dpzi01_kor])-[kc_dpzi03a])-([kc_dpzi04_vyp]+[kc_dpzi04_kor]))-([kc_dpzi05_vyp]+[kc_dpzi05_kor]))),
	[kc_dpzi11]  AS (CONVERT([numeric](19,6),[kc_dpzi11_vyp]+[kc_dpzi11_kor])),
 CONSTRAINT [PK__Tabx_VZDMesVypocet__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__cj_dpzi03]  DEFAULT ('') FOR [cj_dpzi03]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi03a]  DEFAULT ((0.0)) FOR [kc_dpzi03a]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi01_kor]  DEFAULT ((0.0)) FOR [kc_dpzi01_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi01_vyp]  DEFAULT ((0.0)) FOR [kc_dpzi01_vyp]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi02_kor]  DEFAULT ((0.0)) FOR [kc_dpzi02_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi02_vyp]  DEFAULT ((0.0)) FOR [kc_dpzi02_vyp]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi04_kor]  DEFAULT ((0.0)) FOR [kc_dpzi04_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi04_vyp]  DEFAULT ((0.0)) FOR [kc_dpzi04_vyp]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi05_kor]  DEFAULT ((0.0)) FOR [kc_dpzi05_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi05_vyp]  DEFAULT ((0.0)) FOR [kc_dpzi05_vyp]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi06_kor]  DEFAULT ((0.0)) FOR [kc_dpzi06_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi06_vyp]  DEFAULT ((0.0)) FOR [kc_dpzi06_vyp]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi07_kor]  DEFAULT ((0.0)) FOR [kc_dpzi07_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi07_vyp]  DEFAULT ((0.0)) FOR [kc_dpzi07_vyp]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi10]  DEFAULT ((0.0)) FOR [kc_dpzi10]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi11_kor]  DEFAULT ((0.0)) FOR [kc_dpzi11_kor]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__kc_dpzi11_vyp]  DEFAULT ((0.0)) FOR [kc_dpzi11_vyp]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDMesVypocet] ADD  CONSTRAINT [DF__Tabx_VZDMesVypocet__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

