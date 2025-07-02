USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDTextPriloha]    Script Date: 02.07.2025 10:45:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDTextPriloha](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdVZDVDA] [int] NOT NULL,
	[kod_sekce] [nvarchar](1) NOT NULL,
	[poradi] [int] NOT NULL,
	[t_prilohy] [nvarchar](72) NOT NULL,
	[DruhDane] [smallint] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_VZDTextPriloha__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDTextPriloha] ADD  CONSTRAINT [DF__Tabx_VZDTextPriloha__t_prilohy]  DEFAULT ('') FOR [t_prilohy]
GO

ALTER TABLE [dbo].[Tabx_VZDTextPriloha] ADD  CONSTRAINT [DF__Tabx_VZDTextPriloha__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_VZDTextPriloha] ADD  CONSTRAINT [DF__Tabx_VZDTextPriloha__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

