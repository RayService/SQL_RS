USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_masky_SN]    Script Date: 02.07.2025 9:15:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_masky_SN](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Maska] [nvarchar](100) NOT NULL,
	[Nazev] [nvarchar](255) NOT NULL,
	[CisOrg] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_RS_masky_SN__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_masky_SN] ADD  CONSTRAINT [DF__Tabx_RS_masky_SN__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_masky_SN] ADD  CONSTRAINT [DF__Tabx_RS_masky_SN__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

