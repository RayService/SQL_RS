USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_EdExtAtr_Prehledy]    Script Date: 02.07.2025 8:43:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_EdExtAtr_Prehledy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BID] [int] NOT NULL,
	[BrowseName] [nvarchar](255) NOT NULL,
	[TableName] [nvarchar](255) NOT NULL,
	[Soudecek] [nvarchar](255) NOT NULL,
	[Instalovat] [bit] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_EdExtAtr_Prehledy__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_EdExtAtr_Prehledy] ADD  CONSTRAINT [DF__Tabx_EdExtAtr_Prehledy__Instalovat]  DEFAULT ((0)) FOR [Instalovat]
GO

ALTER TABLE [dbo].[Tabx_EdExtAtr_Prehledy] ADD  CONSTRAINT [DF__Tabx_EdExtAtr_Prehledy__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_EdExtAtr_Prehledy] ADD  CONSTRAINT [DF__Tabx_EdExtAtr_Prehledy__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

