USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_translation_log]    Script Date: 02.07.2025 10:09:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_translation_log](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[phrase] [nvarchar](255) NOT NULL,
	[api_version] [nvarchar](4) NOT NULL,
	[code_source] [nvarchar](512) NOT NULL,
	[ip_address] [nvarchar](32) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_RS_translation_log__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_translation_log] ADD  CONSTRAINT [DF__Tabx_RS_translation_log__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_translation_log] ADD  CONSTRAINT [DF__Tabx_RS_translation_log__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

