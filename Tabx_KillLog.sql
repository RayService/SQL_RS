USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_KillLog]    Script Date: 02.07.2025 8:45:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_KillLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Datum] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[loginame] [nvarchar](128) NOT NULL,
	[hostname] [nvarchar](128) NULL,
	[login_time] [datetime] NULL,
	[last_batch] [datetime] NOT NULL,
	[program_name] [nvarchar](128) NULL,
	[db_name] [nvarchar](128) NOT NULL,
	[status] [nvarchar](30) NOT NULL,
	[cmd] [nvarchar](16) NOT NULL,
	[open_tran] [smallint] NOT NULL,
 CONSTRAINT [PK__Tabx_KillLog__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_KillLog] ADD  CONSTRAINT [DF__Tabx_KillLog__Datum]  DEFAULT (getdate()) FOR [Datum]
GO

ALTER TABLE [dbo].[Tabx_KillLog] ADD  CONSTRAINT [DF__Tabx_KillLog__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

