USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_Packin]    Script Date: 02.07.2025 9:26:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_Packin](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_VyrCS_packing] [int] NULL,
	[sirka] [numeric](19, 6) NULL,
	[delka] [numeric](19, 6) NULL,
	[vyska] [numeric](19, 6) NULL,
	[Hmotnost] [numeric](19, 6) NOT NULL,
	[cislo_baleni] [int] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[ID_Item_packing] [int] NOT NULL,
 CONSTRAINT [PK__Tabx_RS_Packin__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_Packin] ADD  CONSTRAINT [DF__Tabx_RS_Packin__sirka]  DEFAULT ((0)) FOR [sirka]
GO

ALTER TABLE [dbo].[Tabx_RS_Packin] ADD  CONSTRAINT [DF__Tabx_RS_Packin__delka]  DEFAULT ((0)) FOR [delka]
GO

ALTER TABLE [dbo].[Tabx_RS_Packin] ADD  CONSTRAINT [DF__Tabx_RS_Packin__vyska]  DEFAULT ((0)) FOR [vyska]
GO

ALTER TABLE [dbo].[Tabx_RS_Packin] ADD  CONSTRAINT [DF__Tabx_RS_Packin__Hmotnost]  DEFAULT ((0)) FOR [Hmotnost]
GO

ALTER TABLE [dbo].[Tabx_RS_Packin] ADD  CONSTRAINT [DF__Tabx_RS_Packin__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_Packin] ADD  CONSTRAINT [DF__Tabx_RS_Packin__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

