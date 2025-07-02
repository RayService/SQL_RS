USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_ReseniHeO_SpidOzn]    Script Date: 02.07.2025 8:54:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_ReseniHeO_SpidOzn](
	[TabName] [nvarchar](128) NOT NULL,
	[SPID] [smallint] NOT NULL,
	[IDTab] [int] NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_ReseniHeO_SpidOzn__TabName__SPID__IDTab] PRIMARY KEY CLUSTERED 
(
	[TabName] ASC,
	[SPID] ASC,
	[IDTab] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_ReseniHeO_SpidOzn] ADD  CONSTRAINT [DF__Tabx_ReseniHeO_SpidOzn__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

