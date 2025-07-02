USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDPrilOprDB]    Script Date: 02.07.2025 10:43:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDPrilOprDB](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdVZDVDA] [int] NOT NULL,
	[b_d_dodsraz] [datetime] NULL,
	[b_d_puvsraz] [datetime] NULL,
	[b_d_zadosti] [datetime] NULL,
	[b_kc_castka] [numeric](19, 6) NOT NULL,
	[b_mesic_nespr] [smallint] NULL,
	[b_mesic_opr] [smallint] NOT NULL,
	[b_pr_opr] [nvarchar](1) NOT NULL,
	[b_rok_nespr] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[b_rok_opr] [int] NULL,
 CONSTRAINT [PK__Tabx_VZDPrilOprDB__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDB] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDB__b_kc_castka]  DEFAULT ((0.0)) FOR [b_kc_castka]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDB] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDB__b_mesic_opr]  DEFAULT ((1)) FOR [b_mesic_opr]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDB] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDB__b_pr_opr]  DEFAULT (N'M') FOR [b_pr_opr]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDB] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDB__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDB] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDB__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

