USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SDDuvody]    Script Date: 02.07.2025 10:22:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SDDuvody](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Duvod] [nvarchar](100) NOT NULL,
	[TypSchvaleni] [tinyint] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_SDDuvody__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SDDuvody] ADD  CONSTRAINT [DF__Tabx_SDDuvody__TypSchvaleni]  DEFAULT ((1)) FOR [TypSchvaleni]
GO

ALTER TABLE [dbo].[Tabx_SDDuvody] ADD  CONSTRAINT [DF__Tabx_SDDuvody__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_SDDuvody] ADD  CONSTRAINT [DF__Tabx_SDDuvody__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

