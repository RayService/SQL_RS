USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_VZDCiselnikFU]    Script Date: 02.07.2025 10:39:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_VZDCiselnikFU](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Cislo] [nvarchar](4) NOT NULL,
	[FinUrad] [nvarchar](255) NOT NULL,
	[c_pracufo] [nvarchar](4) NULL,
 CONSTRAINT [PK__Tabx_VZDCiselnikFU__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_VZDCiselnikFU] ADD  CONSTRAINT [DF__Tabx_VZDCiselnikFU__Cislo]  DEFAULT ('') FOR [Cislo]
GO

ALTER TABLE [dbo].[Tabx_VZDCiselnikFU] ADD  CONSTRAINT [DF__Tabx_VZDCiselnikFU__FinUrad]  DEFAULT ('') FOR [FinUrad]
GO

