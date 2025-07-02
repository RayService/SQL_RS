USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_BONProcessPower]    Script Date: 02.07.2025 9:00:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_BONProcessPower](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZam] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Item01] [numeric](19, 6) NULL,
	[Attendance01] [numeric](19, 6) NULL,
	[Item02] [numeric](19, 6) NULL,
	[Attendance02] [numeric](19, 6) NULL,
	[Item03] [numeric](19, 6) NULL,
	[Attendance03] [numeric](19, 6) NULL,
	[Item04] [numeric](19, 6) NULL,
	[Attendance04] [numeric](19, 6) NULL,
	[Item05] [numeric](19, 6) NULL,
	[Attendance05] [numeric](19, 6) NULL,
	[Item06] [numeric](19, 6) NULL,
	[Attendance06] [numeric](19, 6) NULL,
	[Item07] [numeric](19, 6) NULL,
	[Attendance07] [numeric](19, 6) NULL,
	[Item08] [numeric](19, 6) NULL,
	[Attendance08] [numeric](19, 6) NULL,
	[Item09] [numeric](19, 6) NULL,
	[Attendance09] [numeric](19, 6) NULL,
	[Item10] [numeric](19, 6) NULL,
	[Attendance10] [numeric](19, 6) NULL,
	[Item11] [numeric](19, 6) NULL,
	[Attendance11] [numeric](19, 6) NULL,
	[Item12] [numeric](19, 6) NULL,
	[Attendance12] [numeric](19, 6) NULL,
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
	[ItemYear]  AS ((((((((((([Item01]+[Item02])+[Item03])+[Item04])+[Item05])+[Item06])+[Item07])+[Item08])+[Item09])+[Item10])+[Item11])+[Item12]),
	[AttendanceYear]  AS ((((((((((([Attendance01]+[Attendance02])+[Attendance03])+[Attendance04])+[Attendance05])+[Attendance06])+[Attendance07])+[Attendance08])+[Attendance09])+[Attendance10])+[Attendance11])+[Attendance12]),
	[Vykon12]  AS ([Item12]/nullif([Attendance12],(0))),
	[Vykon11]  AS ([Item11]/nullif([Attendance11],(0))),
	[Vykon10]  AS ([Item10]/nullif([Attendance10],(0))),
	[Vykon09]  AS ([Item09]/nullif([Attendance09],(0))),
	[Vykon08]  AS ([Item08]/nullif([Attendance08],(0))),
	[Vykon07]  AS ([Item07]/nullif([Attendance07],(0))),
	[Vykon06]  AS ([Item06]/nullif([Attendance06],(0))),
	[Vykon05]  AS ([Item05]/nullif([Attendance05],(0))),
	[Vykon04]  AS ([Item04]/nullif([Attendance04],(0))),
	[Vykon03]  AS ([Item03]/nullif([Attendance03],(0))),
	[Vykon02]  AS ([Item02]/nullif([Attendance02],(0))),
	[Vykon01]  AS ([Item01]/nullif([Attendance01],(0))),
	[VykonYear]  AS (((((((((((([Item01]+[Item02])+[Item03])+[Item04])+[Item05])+[Item06])+[Item07])+[Item08])+[Item09])+[Item10])+[Item11])+[Item12])/nullif((((((((((([Attendance01]+[Attendance02])+[Attendance03])+[Attendance04])+[Attendance05])+[Attendance06])+[Attendance07])+[Attendance08])+[Attendance09])+[Attendance10])+[Attendance11])+[Attendance12],(0))),
 CONSTRAINT [PK__Tabx_RS_BONProcessPower__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item01]  DEFAULT ((0)) FOR [Item01]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance01]  DEFAULT ((0)) FOR [Attendance01]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item02]  DEFAULT ((0)) FOR [Item02]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance02]  DEFAULT ((0)) FOR [Attendance02]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item03]  DEFAULT ((0)) FOR [Item03]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance03]  DEFAULT ((0)) FOR [Attendance03]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item04]  DEFAULT ((0)) FOR [Item04]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance04]  DEFAULT ((0)) FOR [Attendance04]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item05]  DEFAULT ((0)) FOR [Item05]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance05]  DEFAULT ((0)) FOR [Attendance05]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item06]  DEFAULT ((0)) FOR [Item06]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance06]  DEFAULT ((0)) FOR [Attendance06]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item07]  DEFAULT ((0)) FOR [Item07]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance07]  DEFAULT ((0)) FOR [Attendance07]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item08]  DEFAULT ((0)) FOR [Item08]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance08]  DEFAULT ((0)) FOR [Attendance08]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item09]  DEFAULT ((0)) FOR [Item09]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance09]  DEFAULT ((0)) FOR [Attendance09]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item10]  DEFAULT ((0)) FOR [Item10]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance10]  DEFAULT ((0)) FOR [Attendance10]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item11]  DEFAULT ((0)) FOR [Item11]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance11]  DEFAULT ((0)) FOR [Attendance11]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Item12]  DEFAULT ((0)) FOR [Item12]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Attendance12]  DEFAULT ((0)) FOR [Attendance12]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_BONProcessPower] ADD  CONSTRAINT [DF__Tabx_RS_BONProcessPower__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

