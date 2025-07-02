USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SDZastupitelnost]    Script Date: 02.07.2025 10:28:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SDZastupitelnost](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LoginNameSchvalovatel] [nvarchar](128) NOT NULL,
	[LoginNameZastupce] [nvarchar](128) NOT NULL,
	[IdPredpis] [int] NULL,
	[PlatnostOd] [datetime] NULL,
	[PlatnostDo] [datetime] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[DatZmeny] [datetime] NULL,
	[Zmenil] [nvarchar](128) NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_SDZastupitelnost__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SDZastupitelnost] ADD  CONSTRAINT [DF__Tabx_SDZastupitelnost__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_SDZastupitelnost] ADD  CONSTRAINT [DF__Tabx_SDZastupitelnost__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_SDZastupitelnost]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_SDZastupitelnost__IdPredpis] FOREIGN KEY([IdPredpis])
REFERENCES [dbo].[Tabx_SDPredpisy] ([ID])
GO

ALTER TABLE [dbo].[Tabx_SDZastupitelnost] CHECK CONSTRAINT [FK__Tabx_SDZastupitelnost__IdPredpis]
GO

