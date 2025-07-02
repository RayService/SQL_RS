USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_LinkIssueTable]    Script Date: 02.07.2025 9:11:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_LinkIssueTable](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDDoklad] [int] NOT NULL,
	[IDTable] [int] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny])))),
 CONSTRAINT [PK__Tabx_RS_LinkIssueTable__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_LinkIssueTable] ADD  CONSTRAINT [DF__Tabx_RS_LinkIssueTable__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_LinkIssueTable] ADD  CONSTRAINT [DF__Tabx_RS_LinkIssueTable__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_LinkIssueTable]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_LinkIssueTable__IDDoklad] FOREIGN KEY([IDDoklad])
REFERENCES [dbo].[TabDokladyZbozi] ([ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Tabx_RS_LinkIssueTable] CHECK CONSTRAINT [FK__Tabx_RS_LinkIssueTable__IDDoklad]
GO

ALTER TABLE [dbo].[Tabx_RS_LinkIssueTable]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_LinkIssueTable__IDTable] FOREIGN KEY([IDTable])
REFERENCES [dbo].[Tabx_RS_workplace_tables] ([ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Tabx_RS_LinkIssueTable] CHECK CONSTRAINT [FK__Tabx_RS_LinkIssueTable__IDTable]
GO

