USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SHTools_RetezecBlokovani]    Script Date: 02.07.2025 10:34:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SHTools_RetezecBlokovani](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Retezec] [nvarchar](100) NULL,
	[SPID] [smallint] NOT NULL,
	[ECID] [smallint] NULL,
	[LoginName] [nchar](128) NOT NULL,
	[HostName] [nchar](128) NOT NULL,
	[ProgramName] [nchar](128) NOT NULL,
	[DbName] [nvarchar](128) NULL,
	[ObjectId] [nvarchar](128) NULL,
	[Query] [nvarchar](max) NULL,
	[ParentQuery] [nvarchar](max) NULL,
	[Deadlock] [bit] NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK__Tabx_SHTools_RetezecBlokovani__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SHTools_RetezecBlokovani] ADD  CONSTRAINT [DF__Tabx_SHTools_RetezecBlokovani__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_SHTools_RetezecBlokovani] ADD  CONSTRAINT [DF__Tabx_SHTools_RetezecBlokovani__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

