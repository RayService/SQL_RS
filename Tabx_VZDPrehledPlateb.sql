USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDPrehledPlateb]    Script Date: 02.07.2025 10:42:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDPrehledPlateb](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[d_zadosti_06] [datetime] NULL,
	[mesic_06] [tinyint] NULL,
	[uhrnprepl_c] [numeric](19, 6) NOT NULL,
	[uhrnprepl_z] [numeric](19, 6) NOT NULL,
	[IdVZDVDA] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_VZDPrehledPlateb__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDPrehledPlateb] ADD  CONSTRAINT [DF__Tabx_VZDPrehledPlateb__uhrnprepl_c]  DEFAULT ((0.0)) FOR [uhrnprepl_c]
GO

ALTER TABLE [dbo].[Tabx_VZDPrehledPlateb] ADD  CONSTRAINT [DF__Tabx_VZDPrehledPlateb__uhrnprepl_z]  DEFAULT ((0.0)) FOR [uhrnprepl_z]
GO

ALTER TABLE [dbo].[Tabx_VZDPrehledPlateb] ADD  CONSTRAINT [DF__Tabx_VZDPrehledPlateb__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDPrehledPlateb] ADD  CONSTRAINT [DF__Tabx_VZDPrehledPlateb__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

