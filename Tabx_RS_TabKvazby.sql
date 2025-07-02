USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_RS_TabKvazby]    Script Date: 02.07.2025 9:52:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_RS_TabKvazby](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[vyssi] [int] NOT NULL,
	[IDVarianta] [int] NULL,
	[nizsi] [int] NOT NULL,
	[ZmenaOd] [int] NULL,
	[ZmenaDo] [int] NULL,
	[pozice] [nvarchar](100) NULL,
	[Operace] [nchar](4) NULL,
	[mnozstvi] [numeric](19, 6) NOT NULL,
	[ProcZtrat] [numeric](5, 2) NOT NULL,
	[Prirez] [numeric](19, 6) NOT NULL,
	[Poznamka] [nvarchar](max) NULL,
	[ID1] [int] NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[mnozstviSeZtratou] [numeric](19, 6) NOT NULL,
	[IDVzorceSpotMat] [int] NULL,
	[PromA] [numeric](19, 6) NULL,
	[PromB] [numeric](19, 6) NULL,
	[PromC] [numeric](19, 6) NULL,
	[PromD] [numeric](19, 6) NULL,
	[PromE] [numeric](19, 6) NULL,
	[SpotRozmer] [nvarchar](100) NULL,
	[FixniMnozstvi] [numeric](19, 6) NOT NULL,
	[DavkaTPV] [numeric](19, 6) NOT NULL,
	[globalni]  AS (CONVERT([bit],case when [IDVarianta] IS NULL then (1) else (0) end,(0))),
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni],(0)),(0)),(0))),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny],(0)),(0)),(0))),
	[RezijniMat] [bit] NOT NULL,
	[VyraditZKalkulace] [bit] NOT NULL,
	[IDZakazModif] [int] NULL,
	[JeZakazModif]  AS (CONVERT([bit],case when [IDZakazModif] IS NULL then (0) else (1) end,(0))),
	[VychoziSklad] [nvarchar](30) NULL,
	[UzivZadaniPrirezu]  AS (CONVERT([bit],case when [mnozstvi]>(0.0) AND [mnozstvi]=[Prirez] OR [mnozstvi]=(0.0) AND [FixniMnozstvi]=[Prirez] then (0) else (1) end,(0))),
	[IDPohybu] [int] NOT NULL,
	[IDVazby] [int] NOT NULL,
	[mnoz_zad] [numeric](19, 6) NULL,
 CONSTRAINT [PK__Tabx_RS_TabKvazby__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__pozice]  DEFAULT ('') FOR [pozice]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__ProcZtrat]  DEFAULT ((0)) FOR [ProcZtrat]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__ID1]  DEFAULT ((0)) FOR [ID1]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__mnozstviSeZtratou]  DEFAULT ((0)) FOR [mnozstviSeZtratou]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__FixniMnozstvi]  DEFAULT ((0)) FOR [FixniMnozstvi]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__DavkaTPV]  DEFAULT ((1)) FOR [DavkaTPV]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__RezijniMat]  DEFAULT ((0)) FOR [RezijniMat]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] ADD  CONSTRAINT [DF__Tabx_RS_TabKvazby__VyraditZKalkulace]  DEFAULT ((0)) FOR [VyraditZKalkulace]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TabKvazby__IDVarianta] FOREIGN KEY([IDVarianta])
REFERENCES [dbo].[TabCVariant] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [FK__Tabx_RS_TabKvazby__IDVarianta]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TabKvazby__IDVzorceSpotMat] FOREIGN KEY([IDVzorceSpotMat])
REFERENCES [dbo].[TabCVzorcuSpotMat] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [FK__Tabx_RS_TabKvazby__IDVzorceSpotMat]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TabKvazby__IDZakazModif] FOREIGN KEY([IDZakazModif])
REFERENCES [dbo].[TabZakazModif] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [FK__Tabx_RS_TabKvazby__IDZakazModif]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TabKvazby__nizsi] FOREIGN KEY([nizsi])
REFERENCES [dbo].[TabKmenZbozi] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [FK__Tabx_RS_TabKvazby__nizsi]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TabKvazby__VychoziSklad] FOREIGN KEY([VychoziSklad])
REFERENCES [dbo].[TabStrom] ([Cislo])
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [FK__Tabx_RS_TabKvazby__VychoziSklad]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TabKvazby__vyssi] FOREIGN KEY([vyssi])
REFERENCES [dbo].[TabKmenZbozi] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [FK__Tabx_RS_TabKvazby__vyssi]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TabKvazby__ZmenaDo] FOREIGN KEY([ZmenaDo])
REFERENCES [dbo].[TabCzmeny] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [FK__Tabx_RS_TabKvazby__ZmenaDo]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_RS_TabKvazby__ZmenaOd] FOREIGN KEY([ZmenaOd])
REFERENCES [dbo].[TabCzmeny] ([ID])
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [FK__Tabx_RS_TabKvazby__ZmenaOd]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_TabKvazby__DavkaTPV] CHECK  (([DavkaTPV]>(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [CK__Tabx_RS_TabKvazby__DavkaTPV]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_TabKvazby__FixniMnozstvi] CHECK  (([FixniMnozstvi]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [CK__Tabx_RS_TabKvazby__FixniMnozstvi]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_TabKvazby__IDVarianta] CHECK  (([IDVarianta] IS NULL OR [IDZakazModif] IS NULL))
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [CK__Tabx_RS_TabKvazby__IDVarianta]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_TabKvazby__mnozstvi] CHECK  (([mnozstvi]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [CK__Tabx_RS_TabKvazby__mnozstvi]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_TabKvazby__mnozstviSeZtratou] CHECK  (([mnozstviSeZtratou]>=[mnozstvi]))
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [CK__Tabx_RS_TabKvazby__mnozstviSeZtratou]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_TabKvazby__Prirez] CHECK  (([Prirez]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [CK__Tabx_RS_TabKvazby__Prirez]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_TabKvazby__ProcZtrat] CHECK  (([ProcZtrat]>=(0)))
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [CK__Tabx_RS_TabKvazby__ProcZtrat]
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_RS_TabKvazby__ZmenaOd] CHECK  (([ZmenaOd] IS NULL AND [ZmenaDo] IS NULL AND [IDZakazModif] IS NOT NULL OR [ZmenaOd] IS NOT NULL AND [IDZakazModif] IS NULL))
GO

ALTER TABLE [dbo].[Tabx_RS_TabKvazby] CHECK CONSTRAINT [CK__Tabx_RS_TabKvazby__ZmenaOd]
GO

