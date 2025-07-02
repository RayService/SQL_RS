USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_Packing_Doklad]    Script Date: 02.07.2025 9:26:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_Packing_Doklad](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_VyrCP_Item] [int] NOT NULL,
	[ID_baleni] [int] NULL,
	[Mnozstvi] [numeric](19, 6) NULL,
	[Poznamka] [ntext] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_RS_Packing_Doklad__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_Packing_Doklad] ADD  CONSTRAINT [DF__Tabx_RS_Packing_Doklad__Mnozstvi]  DEFAULT ((0)) FOR [Mnozstvi]
GO

ALTER TABLE [dbo].[Tabx_RS_Packing_Doklad] ADD  CONSTRAINT [DF__Tabx_RS_Packing_Doklad__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_Packing_Doklad] ADD  CONSTRAINT [DF__Tabx_RS_Packing_Doklad__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

