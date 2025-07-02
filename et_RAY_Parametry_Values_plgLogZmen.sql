USE [HCvicna]
GO

/****** Object:  Table [dbo].[RAY_Parametry_Values]    Script Date: 02.07.2025 13:10:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RAY_Parametry_Values](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_Param] [int] NOT NULL,
	[Mesic] [nvarchar](50) NOT NULL,
	[Mesic_value] [numeric](19, 6) NULL,
	[Kumulativ_value] [numeric](19, 6) NULL,
	[Result_koef_uziv] [numeric](19, 6) NULL,
	[Target_value_from] [numeric](19, 6) NULL,
	[Result] [ntext] NULL,
	[Opatreni] [ntext] NULL,
	[Target_value_to] [numeric](19, 6) NULL,
	[Result_koef_calc] [numeric](19, 6) NULL,
	[Mesic_cislo] [int] NULL,
	[Rok] [int] NULL,
 CONSTRAINT [PK_RAY_Parametry_values] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

