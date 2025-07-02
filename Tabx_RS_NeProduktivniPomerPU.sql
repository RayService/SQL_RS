USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_NeProduktivniPomerPU]    Script Date: 02.07.2025 9:22:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_NeProduktivniPomerPU](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductionUnitID] [int] NOT NULL,
	[UnProductiveTime] [numeric](19, 6) NULL,
	[ProductiveTime] [numeric](19, 6) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[UnproductivePerc]  AS (([UnProductiveTime]/([UnProductiveTime]+[ProductiveTime]))*(100)),
	[ProductivePerc]  AS (([ProductiveTime]/([UnProductiveTime]+[ProductiveTime]))*(100)),
 CONSTRAINT [PK__Tabx_RS_NeProduktivniPomerPU__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_NeProduktivniPomerPU] ADD  CONSTRAINT [DF__Tabx_RS_NeProduktivniPomerPU__UnProductiveTime]  DEFAULT ((0)) FOR [UnProductiveTime]
GO

ALTER TABLE [dbo].[Tabx_RS_NeProduktivniPomerPU] ADD  CONSTRAINT [DF__Tabx_RS_NeProduktivniPomerPU__ProductiveTime]  DEFAULT ((0)) FOR [ProductiveTime]
GO

ALTER TABLE [dbo].[Tabx_RS_NeProduktivniPomerPU] ADD  CONSTRAINT [DF__Tabx_RS_NeProduktivniPomerPU__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_NeProduktivniPomerPU] ADD  CONSTRAINT [DF__Tabx_RS_NeProduktivniPomerPU__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

