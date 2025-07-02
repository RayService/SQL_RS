USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDPocZam]    Script Date: 02.07.2025 10:40:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDPocZam](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdVZDVDA] [int] NOT NULL,
	[c_obce_zuj] [int] NULL,
	[c_zko] [int] NULL,
	[naz_obce_zuj] [nvarchar](40) NOT NULL,
	[naz_vykonu] [nvarchar](40) NOT NULL,
	[naz_zko] [nvarchar](23) NOT NULL,
	[poc_zam] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_VZDPocZam__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDPocZam] ADD  CONSTRAINT [DF__Tabx_VZDPocZam__naz_obce_zuj]  DEFAULT ('') FOR [naz_obce_zuj]
GO

ALTER TABLE [dbo].[Tabx_VZDPocZam] ADD  CONSTRAINT [DF__Tabx_VZDPocZam__naz_vykonu]  DEFAULT ('') FOR [naz_vykonu]
GO

ALTER TABLE [dbo].[Tabx_VZDPocZam] ADD  CONSTRAINT [DF__Tabx_VZDPocZam__naz_zko]  DEFAULT ('') FOR [naz_zko]
GO

ALTER TABLE [dbo].[Tabx_VZDPocZam] ADD  CONSTRAINT [DF__Tabx_VZDPocZam__poc_zam]  DEFAULT ((0)) FOR [poc_zam]
GO

ALTER TABLE [dbo].[Tabx_VZDPocZam] ADD  CONSTRAINT [DF__Tabx_VZDPocZam__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDPocZam] ADD  CONSTRAINT [DF__Tabx_VZDPocZam__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

