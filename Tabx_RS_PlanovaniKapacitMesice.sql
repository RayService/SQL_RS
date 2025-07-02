USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_PlanovaniKapacitMesice]    Script Date: 02.07.2025 9:30:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_PlanovaniKapacitMesice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MesicCislo] [int] NOT NULL,
	[MesicNazev] [nvarchar](20) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[ActualOrder] [int] NULL,
 CONSTRAINT [PK__Tabx_RS_PlanovaniKapacitMesice__MesicCislo] PRIMARY KEY CLUSTERED 
(
	[MesicCislo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitMesice] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitMesice__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_PlanovaniKapacitMesice] ADD  CONSTRAINT [DF__Tabx_RS_PlanovaniKapacitMesice__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

