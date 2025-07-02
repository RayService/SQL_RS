USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_Robot_Finder_Found]    Script Date: 02.07.2025 9:43:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_Robot_Finder_Found](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_master] [int] NOT NULL,
	[ID_slave] [int] NOT NULL,
	[File_ID_master] [nvarchar](255) NOT NULL,
	[File_ID_slave] [nvarchar](255) NOT NULL,
	[Matched] [bit] NOT NULL,
	[Result] [bit] NOT NULL,
	[Marker] [nvarchar](128) NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_RS_Robot_Finder_Found__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_Robot_Finder_Found] ADD  CONSTRAINT [DF__Tabx_RS_Robot_Finder_Found__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_Robot_Finder_Found] ADD  CONSTRAINT [DF__Tabx_RS_Robot_Finder_Found__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

