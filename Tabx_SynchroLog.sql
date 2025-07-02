USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_SynchroLog]    Script Date: 02.07.2025 10:35:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_SynchroLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Tab] [nvarchar](128) NOT NULL,
	[IdTab] [int] NOT NULL,
	[TypSynchro] [tinyint] NOT NULL,
	[IdTabCil] [int] NULL,
	[DatPorizeni] [datetime] NULL,
	[Autor] [nvarchar](128) NULL,
	[DatSynchro] [datetime] NULL,
	[Synchronizoval] [nvarchar](128) NULL,
	[Zprava] [nvarchar](255) NULL,
	[Synchro] [bit] NOT NULL,
 CONSTRAINT [PK__Tabx_SynchroLog__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__Tabx_SynchroLog__TypSynchro_Tab_IdTab] UNIQUE NONCLUSTERED 
(
	[TypSynchro] ASC,
	[Tab] ASC,
	[IdTab] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_SynchroLog] ADD  CONSTRAINT [DF__Tabx_SynchroLog__TypSynchro]  DEFAULT ((0)) FOR [TypSynchro]
GO

ALTER TABLE [dbo].[Tabx_SynchroLog] ADD  CONSTRAINT [DF__Tabx_SynchroLog__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_SynchroLog] ADD  CONSTRAINT [DF__Tabx_SynchroLog__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_SynchroLog] ADD  CONSTRAINT [DF__Tabx_SynchroLog__Zprava]  DEFAULT ('') FOR [Zprava]
GO

ALTER TABLE [dbo].[Tabx_SynchroLog] ADD  CONSTRAINT [DF__Tabx_SynchroLog__Synchro]  DEFAULT ((0)) FOR [Synchro]
GO

