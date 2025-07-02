USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SDLog]    Script Date: 02.07.2025 10:23:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SDLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TypZaznamu] [tinyint] NOT NULL,
	[Udalost] [nvarchar](4000) NULL,
	[IdDoklad] [int] NULL,
	[TypDokladu] [tinyint] NOT NULL,
	[SchvaleniStav] [tinyint] NOT NULL,
	[SchvaleniUroven] [int] NULL,
	[SchvaleniPoznamka] [ntext] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[SchvaleniPoznamka_255]  AS (substring(replace(substring([SchvaleniPoznamka],(1),(255)),nchar((13))+nchar((10)),nchar((32))),(1),(255))),
	[SchvaleniPoznamka_all]  AS ([SchvaleniPoznamka]),
 CONSTRAINT [PK__Tabx_SDLog__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SDLog] ADD  CONSTRAINT [DF__Tabx_SDLog__TypZaznamu]  DEFAULT ((0)) FOR [TypZaznamu]
GO

ALTER TABLE [dbo].[Tabx_SDLog] ADD  CONSTRAINT [DF__Tabx_SDLog__TypDokladu]  DEFAULT ((0)) FOR [TypDokladu]
GO

ALTER TABLE [dbo].[Tabx_SDLog] ADD  CONSTRAINT [DF__Tabx_SDLog__SchvaleniStav]  DEFAULT ((0)) FOR [SchvaleniStav]
GO

ALTER TABLE [dbo].[Tabx_SDLog] ADD  CONSTRAINT [DF__Tabx_SDLog__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_SDLog] ADD  CONSTRAINT [DF__Tabx_SDLog__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

