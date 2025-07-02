USE [HCvicna]
GO

/****** Object:  Table [dbo].[TabCisKOs_EXT]    Script Date: 02.07.2025 13:22:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TabCisKOs_EXT](
	[ID] [int] NOT NULL,
	[_KontNeakt] [bit] NULL,
	[_konicky_zajmy] [nvarchar](255) NULL,
	[_Osob_rodinne_inf] [ntext] NULL,
	[_poznamka] [nvarchar](255) NULL,
	[_email_zpravy] [bit] NULL,
	[_typ_darku] [nvarchar](10) NULL,
	[_zaslat_kalendar] [bit] NULL,
	[_EXT_RS_ComLanguage] [int] NULL,
 CONSTRAINT [PK__TabCisKOs_EXT__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

