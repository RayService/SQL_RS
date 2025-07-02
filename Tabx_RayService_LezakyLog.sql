USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RayService_LezakyLog]    Script Date: 02.07.2025 8:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RayService_LezakyLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Obdobi] [nchar](6) NOT NULL,
	[IDSklad] [nvarchar](30) NOT NULL,
	[DatumDo] [datetime] NOT NULL,
	[PocetMesicu] [smallint] NOT NULL,
	[ProcentoVydej] [numeric](5, 2) NOT NULL,
	[Podminky] [bit] NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[Datum] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_RayService_LezakyLog__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__Tabx_RayService_LezakyLog__Obdobi_IDSklad] UNIQUE NONCLUSTERED 
(
	[Obdobi] ASC,
	[IDSklad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RayService_LezakyLog] ADD  CONSTRAINT [DF__Tabx_RayService_LezakyLog__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RayService_LezakyLog] ADD  CONSTRAINT [DF__Tabx_RayService_LezakyLog__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

