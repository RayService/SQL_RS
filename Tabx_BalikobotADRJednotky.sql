USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotADRJednotky]    Script Date: 02.07.2025 8:24:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotADRJednotky](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KodDopravce] [nvarchar](20) NULL,
	[unit_id] [nvarchar](20) NOT NULL,
	[unit_code] [nvarchar](50) NULL,
	[unit_name] [nvarchar](400) NULL,
	[unit_class] [nvarchar](50) NULL,
	[unit_packaging] [nvarchar](50) NULL,
	[unit_tunnel_code] [nvarchar](50) NULL,
	[unit_transport_category] [nvarchar](50) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotADRJednotky__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotADRJednotky] ADD  CONSTRAINT [DF__Tabx_BalikobotADRJednotky__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotADRJednotky] ADD  CONSTRAINT [DF__Tabx_BalikobotADRJednotky__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

