USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotOdbernaMista]    Script Date: 02.07.2025 8:32:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotOdbernaMista](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KodDopravce] [nvarchar](20) NOT NULL,
	[service_type] [nvarchar](50) NULL,
	[branch_id] [nvarchar](100) NULL,
	[branch_name] [nvarchar](255) NULL,
	[branch_street] [nvarchar](100) NULL,
	[branch_city] [nvarchar](100) NULL,
	[branch_zip] [nvarchar](50) NULL,
	[branch_country] [nvarchar](5) NULL,
	[max_weight] [numeric](19, 2) NULL,
	[Distribucni] [bit] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotOdbernaMista__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotOdbernaMista] ADD  CONSTRAINT [DF__Tabx_BalikobotOdbernaMista__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotOdbernaMista] ADD  CONSTRAINT [DF__Tabx_BalikobotOdbernaMista__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_BalikobotOdbernaMista]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotOdbernaMista__KodDopravce] FOREIGN KEY([KodDopravce])
REFERENCES [dbo].[Tabx_BalikobotDopravci] ([KodDopravce])
GO

ALTER TABLE [dbo].[Tabx_BalikobotOdbernaMista] CHECK CONSTRAINT [FK__Tabx_BalikobotOdbernaMista__KodDopravce]
GO

