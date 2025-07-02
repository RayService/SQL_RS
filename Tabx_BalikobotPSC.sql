USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotPSC]    Script Date: 02.07.2025 8:33:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotPSC](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KodDopravce] [nvarchar](20) NOT NULL,
	[service_type] [nvarchar](50) NULL,
	[zip] [nvarchar](50) NULL,
	[zip_start] [nvarchar](50) NULL,
	[zip_end] [nvarchar](50) NULL,
	[country] [nvarchar](5) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotPSC__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotPSC] ADD  CONSTRAINT [DF__Tabx_BalikobotPSC__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotPSC] ADD  CONSTRAINT [DF__Tabx_BalikobotPSC__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_BalikobotPSC]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotPSC__KodDopravce] FOREIGN KEY([KodDopravce])
REFERENCES [dbo].[Tabx_BalikobotDopravci] ([KodDopravce])
GO

ALTER TABLE [dbo].[Tabx_BalikobotPSC] CHECK CONSTRAINT [FK__Tabx_BalikobotPSC__KodDopravce]
GO

