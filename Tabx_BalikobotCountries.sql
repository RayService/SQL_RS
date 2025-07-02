USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotCountries]    Script Date: 02.07.2025 8:26:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotCountries](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[name_en] [nvarchar](50) NULL,
	[name_cz] [nvarchar](50) NULL,
	[iso_code] [nvarchar](3) NULL,
	[phone_prefix] [nvarchar](10) NULL,
	[currency] [nvarchar](3) NULL,
	[continent] [nvarchar](30) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotCountries__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotCountries] ADD  CONSTRAINT [DF__Tabx_BalikobotCountries__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotCountries] ADD  CONSTRAINT [DF__Tabx_BalikobotCountries__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

