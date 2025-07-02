USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RayService_MatVyrFaze]    Script Date: 02.07.2025 8:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RayService_MatVyrFaze](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDKmenZbozi] [int] NOT NULL,
	[IDTypPostup] [int] NOT NULL,
	[Poradi] [tinyint] NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatZmeny] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
 CONSTRAINT [PK__Tabx_RayService_MatVyrFaze__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__Tabx_RayService_MatVyrFaze__IDKmenZbozi_IDTypPostup_Poradi] UNIQUE NONCLUSTERED 
(
	[IDKmenZbozi] ASC,
	[IDTypPostup] ASC,
	[Poradi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RayService_MatVyrFaze] ADD  CONSTRAINT [DF__Tabx_RayService_MatVyrFaze__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RayService_MatVyrFaze] ADD  CONSTRAINT [DF__Tabx_RayService_MatVyrFaze__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

