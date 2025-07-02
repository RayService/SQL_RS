USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotManipulacniJednotky]    Script Date: 02.07.2025 8:31:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotManipulacniJednotky](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KodDopravce] [nvarchar](20) NULL,
	[unit_code] [nvarchar](50) NOT NULL,
	[unit_name] [nvarchar](100) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotManipulacniJednotky__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotManipulacniJednotky] ADD  CONSTRAINT [DF__Tabx_BalikobotManipulacniJednotky__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotManipulacniJednotky] ADD  CONSTRAINT [DF__Tabx_BalikobotManipulacniJednotky__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

