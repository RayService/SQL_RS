USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_DetailZmenyZmenRizeni]    Script Date: 02.07.2025 9:05:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_DetailZmenyZmenRizeni](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDZmeny] [int] NOT NULL,
	[Oblast] [int] NOT NULL,
	[Vyssi] [int] NOT NULL,
	[nizsi] [int] NOT NULL,
	[IDParentVazby] [int] NULL,
	[IDVazbyOld] [int] NULL,
	[IDVazbyNew] [int] NULL,
	[TypZmeny] [tinyint] NOT NULL,
	[PopisZmeny] [nvarchar](255) NOT NULL,
	[Atribut] [nvarchar](128) NULL,
	[ExtAtribut] [bit] NOT NULL,
	[OldValue] [nvarchar](255) NULL,
	[NewValue] [nvarchar](255) NULL,
	[AltVazba]  AS (CONVERT([bit],case when [IDParentVazby] IS NULL then (0) else (1) end)),
	[IDVazby]  AS (isnull([IDVazbyNew],[IDVazbyOld])),
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
 CONSTRAINT [PK__Tabx_RS_DetailZmenyZmenRizeni__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_DetailZmenyZmenRizeni] ADD  CONSTRAINT [DF__Tabx_RS_DetailZmenyZmenRizeni__ExtAtribut]  DEFAULT ((0)) FOR [ExtAtribut]
GO

ALTER TABLE [dbo].[Tabx_RS_DetailZmenyZmenRizeni] ADD  CONSTRAINT [DF__Tabx_RS_DetailZmenyZmenRizeni__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_DetailZmenyZmenRizeni] ADD  CONSTRAINT [DF__Tabx_RS_DetailZmenyZmenRizeni__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

