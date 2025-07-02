USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RSPersMzdy_Vypocet]    Script Date: 02.07.2025 10:21:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RSPersMzdy_Vypocet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZam] [int] NOT NULL,
	[Vypocet] [smallint] NOT NULL,
	[Algoritmus] [nvarchar](3) NULL,
	[IDPP] [int] NULL,
	[Pozice] [nvarchar](3) NULL,
	[TypMzdy] [smallint] NULL,
	[Mzda] [numeric](19, 6) NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatZmeny] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
 CONSTRAINT [PK__Tabx_RSPersMzdy_Vypocet__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Vypocet] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Vypocet__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Vypocet] ADD  CONSTRAINT [DF__Tabx_RSPersMzdy_Vypocet__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Vypocet]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RSPersMzdy_Vypocet__Pozice] FOREIGN KEY([Pozice])
REFERENCES [dbo].[Tabx_RSPersMzdy_Pozice] ([Kod])
GO

ALTER TABLE [dbo].[Tabx_RSPersMzdy_Vypocet] CHECK CONSTRAINT [FK__Tabx_RSPersMzdy_Vypocet__Pozice]
GO

