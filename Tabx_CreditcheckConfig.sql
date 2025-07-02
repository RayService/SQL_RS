USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_CreditcheckConfig]    Script Date: 02.07.2025 8:39:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_CreditcheckConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Stav1] [int] NULL,
	[Stav2] [int] NULL,
	[Stav3] [int] NULL,
	[Stav4] [int] NULL,
	[CCcode] [nvarchar](100) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[CCcodeSK] [nvarchar](100) NULL,
 CONSTRAINT [PK__Tabx_CreditcheckConfig__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_CreditcheckConfig] ADD  CONSTRAINT [DF__Tabx_CreditcheckConfig__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_CreditcheckConfig] ADD  CONSTRAINT [DF__Tabx_CreditcheckConfig__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

