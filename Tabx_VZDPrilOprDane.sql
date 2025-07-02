USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDPrilOprDane]    Script Date: 02.07.2025 10:42:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDPrilOprDane](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdVZDVDA] [int] NOT NULL,
	[d_dodsraz] [datetime] NULL,
	[d_puvsraz] [datetime] NULL,
	[kc_castka] [numeric](19, 6) NOT NULL,
	[mesic_nespr] [smallint] NULL,
	[mesic_opr] [smallint] NOT NULL,
	[pr_opr] [nvarchar](1) NOT NULL,
	[rok_nespr] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[rok_opr] [int] NULL,
 CONSTRAINT [PK__Tabx_VZDPrilOprDane__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDane] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDane__kc_castka]  DEFAULT ((0.0)) FOR [kc_castka]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDane] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDane__mesic_opr]  DEFAULT ((1)) FOR [mesic_opr]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDane] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDane__pr_opr]  DEFAULT (N'Z') FOR [pr_opr]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDane] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDane__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDPrilOprDane] ADD  CONSTRAINT [DF__Tabx_VZDPrilOprDane__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

