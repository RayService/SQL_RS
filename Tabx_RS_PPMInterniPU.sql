USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PPMInterniPU]    Script Date: 02.07.2025 9:38:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PPMInterniPU](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductionUnitID] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[PocetZmetku] [numeric](19, 6) NULL,
	[PocetOperaci] [numeric](19, 6) NULL,
	[PPMInterni]  AS ((isnull([PocetZmetku],(0))/[PocetOperaci])*(1000000)),
	[BasePPM] [numeric](19, 6) NULL,
 CONSTRAINT [PK__Tabx_RS_PPMInterniPU__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMInterniPU] ADD  CONSTRAINT [DF__Tabx_RS_PPMInterniPU__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PPMInterniPU] ADD  CONSTRAINT [DF__Tabx_RS_PPMInterniPU__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

