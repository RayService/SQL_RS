USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PersMzdy_New_Poznavaci_rozmer]    Script Date: 02.07.2025 9:28:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PersMzdy_New_Poznavaci_rozmer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZam] [int] NOT NULL,
	[Vypocet] [smallint] NOT NULL,
	[Algoritmus] [nvarchar](3) NOT NULL,
	[IDPP] [int] NOT NULL,
	[Soulad] [tinyint] NOT NULL,
	[PP_Kat] [smallint] NOT NULL,
	[PP_KatID] [int] NOT NULL,
	[PP_KatNazev] [nvarchar](150) NULL,
	[PP_DovednostID] [int] NOT NULL,
	[PP_DovednostNazev] [nvarchar](255) NULL,
	[PP_Uroven] [smallint] NOT NULL,
	[PP_UrovenID] [int] NOT NULL,
	[PP_Priorita] [numeric](19, 6) NULL,
	[Z_KatID] [int] NULL,
	[Z_KatNazev] [nvarchar](150) NULL,
	[Z_DovednostID] [int] NULL,
	[Z_DovednostNazev] [nvarchar](255) NULL,
	[Z_Uroven] [smallint] NULL,
	[Z_UrovenID] [int] NULL,
	[Rn_Kat] [int] NULL,
	[Rn_KatUroven] [int] NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK__Tabx_RS_PersMzdy_New_Poznavaci_rozmer__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PersMzdy_New_Poznavaci_rozmer] ADD  CONSTRAINT [DF__Tabx_RS_PersMzdy_New_Poznavaci_rozmer__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_PersMzdy_New_Poznavaci_rozmer] ADD  CONSTRAINT [DF__Tabx_RS_PersMzdy_New_Poznavaci_rozmer__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

