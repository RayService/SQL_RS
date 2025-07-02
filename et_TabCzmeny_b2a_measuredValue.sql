USE [HCvicna]
GO

/****** Object:  Table [dbo].[TabCzmeny]    Script Date: 02.07.2025 13:28:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TabCzmeny](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Rada] [nvarchar](10) NOT NULL,
	[ciszmeny] [nvarchar](15) NOT NULL,
	[navrh] [nvarchar](100) NULL,
	[os_cislo] [int] NULL,
	[Poznamka] [nvarchar](max) NULL,
	[datum] [datetime] NOT NULL,
	[AutorPlatnosti] [nvarchar](128) NULL,
	[datumNastaveni] [datetime] NULL,
	[Platnost] [bit] NOT NULL,
	[PermanentniZmena] [bit] NOT NULL,
	[Logins] [nvarchar](max) NULL,
	[Running] [bit] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[datum_D]  AS (datepart(day,[datum])),
	[datum_M]  AS (datepart(month,[datum])),
	[datum_Y]  AS (datepart(year,[datum])),
	[datum_Q]  AS (datepart(quarter,[datum])),
	[datum_W]  AS (datepart(week,[datum])),
	[datum_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[datum],0),0),0)),
	[datumNastaveni_D]  AS (datepart(day,[datumNastaveni])),
	[datumNastaveni_M]  AS (datepart(month,[datumNastaveni])),
	[datumNastaveni_Y]  AS (datepart(year,[datumNastaveni])),
	[datumNastaveni_Q]  AS (datepart(quarter,[datumNastaveni])),
	[datumNastaveni_W]  AS (datepart(week,[datumNastaveni])),
	[datumNastaveni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[datumNastaveni],0),0),0)),
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni],0),0),0)),
	[DatZmeny_D]  AS (datepart(day,[DatZmeny])),
	[DatZmeny_M]  AS (datepart(month,[DatZmeny])),
	[DatZmeny_Y]  AS (datepart(year,[DatZmeny])),
	[DatZmeny_Q]  AS (datepart(quarter,[DatZmeny])),
	[DatZmeny_W]  AS (datepart(week,[DatZmeny])),
	[DatZmeny_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatZmeny],0),0),0)),
	[IntPermanentniZmena] [bit] NOT NULL,
	[JeNovaVetaEditor] [bit] NOT NULL,
	[DocasnaPlatnost]  AS (CONVERT([bit],case when charindex((nchar((13))+suser_sname())+nchar((13)),CONVERT([nvarchar](4000),isnull([logins],'')))=(0) then (0) else (1) end)),
	[PlatnostTPV]  AS (CONVERT([bit],case when [platnost]=(1) OR charindex((nchar((13))+suser_sname())+nchar((13)),CONVERT([nvarchar](4000),isnull([logins],'')))>(0) then (1) else (0) end)),
	[BlokDP]  AS (CONVERT([bit],case when [logins] IS NULL then (0) else (1) end)),
 CONSTRAINT [PK__TabCzmeny__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__TabCzmeny__Rada__ciszmeny] UNIQUE NONCLUSTERED 
(
	[Rada] ASC,
	[ciszmeny] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[TabCzmeny] ADD  CONSTRAINT [DF__TabCzmeny__navrh]  DEFAULT ('') FOR [navrh]
GO

ALTER TABLE [dbo].[TabCzmeny] ADD  CONSTRAINT [DF__TabCzmeny__Platnost]  DEFAULT ((0)) FOR [Platnost]
GO

ALTER TABLE [dbo].[TabCzmeny] ADD  CONSTRAINT [DF__TabCzmeny__PermanentniZmena]  DEFAULT ((0)) FOR [PermanentniZmena]
GO

ALTER TABLE [dbo].[TabCzmeny] ADD  CONSTRAINT [DF__TabCzmeny__Running]  DEFAULT ((0)) FOR [Running]
GO

ALTER TABLE [dbo].[TabCzmeny] ADD  CONSTRAINT [DF__TabCzmeny__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[TabCzmeny] ADD  CONSTRAINT [DF__TabCzmeny__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[TabCzmeny] ADD  CONSTRAINT [DF__TabCzmeny__IntPermanentniZmena]  DEFAULT ((0)) FOR [IntPermanentniZmena]
GO

ALTER TABLE [dbo].[TabCzmeny] ADD  CONSTRAINT [DF__TabCzmeny__JeNovaVetaEditor]  DEFAULT ((0)) FOR [JeNovaVetaEditor]
GO

ALTER TABLE [dbo].[TabCzmeny]  WITH CHECK ADD  CONSTRAINT [FK__TabCzmeny__os_cislo] FOREIGN KEY([os_cislo])
REFERENCES [dbo].[TabCisZam] ([ID])
GO

ALTER TABLE [dbo].[TabCzmeny] CHECK CONSTRAINT [FK__TabCzmeny__os_cislo]
GO

ALTER TABLE [dbo].[TabCzmeny]  WITH CHECK ADD  CONSTRAINT [FK__TabCzmeny__Rada] FOREIGN KEY([Rada])
REFERENCES [dbo].[TabRadyZmen] ([Rada])
GO

ALTER TABLE [dbo].[TabCzmeny] CHECK CONSTRAINT [FK__TabCzmeny__Rada]
GO

ALTER TABLE [dbo].[TabCzmeny]  WITH CHECK ADD  CONSTRAINT [CK__TabCzmeny__ciszmeny] CHECK  ((len([ciszmeny])>(0)))
GO

ALTER TABLE [dbo].[TabCzmeny] CHECK CONSTRAINT [CK__TabCzmeny__ciszmeny]
GO

ALTER TABLE [dbo].[TabCzmeny]  WITH CHECK ADD  CONSTRAINT [CK__TabCzmeny__IntPermanentniZmena] CHECK  (([IntPermanentniZmena]=(0) OR [Platnost]=(1) AND [PermanentniZmena]=(0)))
GO

ALTER TABLE [dbo].[TabCzmeny] CHECK CONSTRAINT [CK__TabCzmeny__IntPermanentniZmena]
GO

ALTER TABLE [dbo].[TabCzmeny]  WITH CHECK ADD  CONSTRAINT [CK__TabCzmeny__PermanentniZmena] CHECK  (([PermanentniZmena]=(0) OR [Platnost]=(1)))
GO

ALTER TABLE [dbo].[TabCzmeny] CHECK CONSTRAINT [CK__TabCzmeny__PermanentniZmena]
GO

