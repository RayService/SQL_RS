USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotLogovani]    Script Date: 02.07.2025 8:30:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotLogovani](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[URLAkce] [nvarchar](255) NULL,
	[JSONRequest] [nvarchar](max) NULL,
	[JSONResponse] [nvarchar](max) NULL,
	[EXEParam] [nvarchar](255) NULL,
	[WindowsUser] [nvarchar](128) NULL,
	[ErrorMsg] [nvarchar](255) NULL,
	[StatusCode] [int] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Poradi]  AS ([ID]),
	[JSONRequest_All]  AS (substring([JSONRequest],(1),(255))),
	[JSONResponse_All]  AS (substring([JSONResponse],(1),(255))),
	[EXEversion] [nvarchar](50) NULL,
	[DLLversion] [nvarchar](50) NULL,
 CONSTRAINT [PK__Tabx_BalikobotLogovani__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotLogovani] ADD  CONSTRAINT [DF__Tabx_BalikobotLogovani__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotLogovani] ADD  CONSTRAINT [DF__Tabx_BalikobotLogovani__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

