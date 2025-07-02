USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_CommunicationMatrix]    Script Date: 02.07.2025 9:03:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_CommunicationMatrix](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CisOrg] [int] NOT NULL,
	[Vzor] [int] NOT NULL,
	[IDResponsibility] [int] NOT NULL,
	[IDEscalRS] [int] NULL,
	[IDDeputyRS] [int] NULL,
	[IDResponsibleRS] [int] NULL,
	[IDResponsiblePartner] [int] NULL,
	[IDDeputyPartner] [int] NULL,
	[IDEscalPartner] [int] NULL,
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
 CONSTRAINT [PK__Tabx_RS_CommunicationMatrix__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_CommunicationMatrix] ADD  CONSTRAINT [DF__Tabx_RS_CommunicationMatrix__Vzor]  DEFAULT ((0)) FOR [Vzor]
GO

ALTER TABLE [dbo].[Tabx_RS_CommunicationMatrix] ADD  CONSTRAINT [DF__Tabx_RS_CommunicationMatrix__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_CommunicationMatrix] ADD  CONSTRAINT [DF__Tabx_RS_CommunicationMatrix__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

