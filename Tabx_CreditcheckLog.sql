USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_CreditcheckLog]    Script Date: 02.07.2025 8:41:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_CreditcheckLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Typ] [tinyint] NOT NULL,
	[Text] [nvarchar](255) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_CreditcheckLog__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_CreditcheckLog] ADD  CONSTRAINT [DF__Tabx_CreditcheckLog__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_CreditcheckLog] ADD  CONSTRAINT [DF__Tabx_CreditcheckLog__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

