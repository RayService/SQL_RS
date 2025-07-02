USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RSPersMzdy_PoziceZarazeniZam]    Script Date: 02.07.2025 10:20:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RSPersMzdy_PoziceZarazeniZam](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZam] [int] NOT NULL,
	[Vypocet] [smallint] NOT NULL,
	[Body_K1] [smallint] NULL,
	[Body_K2] [smallint] NULL,
	[Body_K3] [smallint] NULL,
	[Body_K4] [smallint] NULL,
	[Splnuje_P8] [bit] NULL,
	[Splnuje_P7] [bit] NULL,
	[Splnuje_P6] [bit] NULL,
	[Splnuje_P5] [bit] NULL,
	[Splnuje_P4] [bit] NULL,
	[Splnuje_P3] [bit] NULL,
	[Splnuje_P2] [bit] NULL,
	[Splnuje_P1] [bit] NULL,
	[Pozice] [tinyint] NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[TK_Mzda_K1] [numeric](19, 6) NULL,
	[TK_Mzda_K2] [numeric](19, 6) NULL,
	[TK_Mzda_K3] [numeric](19, 6) NULL,
	[TK_Mzda_Hodinova] [numeric](19, 6) NULL,
	[TK_HodnotaBodu] [numeric](19, 6) NULL,
 CONSTRAINT [PK__Tabx_RSPersMzdy_PoziceZarazeniZam__IDZam__Vypocet] PRIMARY KEY CLUSTERED 
(
	[IDZam] ASC,
	[Vypocet] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceZarazeniZam] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_PoziceZarazeniZam__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceZarazeniZam] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_PoziceZarazeniZam__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceZarazeniZam]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RSPersMzdy_PoziceZarazeniZam__Pozice] FOREIGN KEY([Pozice])
REFERENCES [dbo].[Tabx_RSPersMzdy_Pozice] ([Poradi])
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_PoziceZarazeniZam] CHECK CONSTRAINT [FK__Tabx_RSPersMzdy_PoziceZarazeniZam__Pozice]
GO

