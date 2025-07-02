USE [HCvicna]
GO

/****** Object:  Table [dbo].[Gatema_PohybUmisteni]    Script Date: 02.07.2025 13:04:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Gatema_PohybUmisteni](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDStavSkladu] [int] NOT NULL,
	[IDKmenZbozi] [int] NOT NULL,
	[IDVyrCis] [int] NULL,
	[IDUmisteni] [int] NOT NULL,
	[DruhPohybu] [int] NOT NULL,
	[Mnozstvi] [numeric](19, 6) NOT NULL,
	[IDPohZbo] [int] NULL,
	[IDSDScanData] [int] NULL,
	[IDInvHead] [int] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[IDKolegy] [int] NULL,
	[IDPohybManJed] [int] NULL,
 CONSTRAINT [PK__Gatema_PohybUmisteni__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Gatema_PohybUmisteni] ADD  CONSTRAINT [DF__Gatema_PohybUmisteni__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Gatema_PohybUmisteni] ADD  CONSTRAINT [DF__Gatema_PohybUmisteni__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

