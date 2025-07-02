USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_ISLager]    Script Date: 02.07.2025 9:09:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_ISLager](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Reason] [nvarchar](50) NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[IsLager] [bit] NULL,
	[Row_nr] [int] NULL,
 CONSTRAINT [PK__Tabx_RS_ISLager__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_ISLager] ADD  CONSTRAINT [DF__Tabx_RS_ISLager__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_ISLager] ADD  CONSTRAINT [DF__Tabx_RS_ISLager__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_ISLager] ADD  CONSTRAINT [DF__Tabx_RS_ISLager__IsLager]  DEFAULT ((0)) FOR [IsLager]
GO

