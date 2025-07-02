USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotZasilky]    Script Date: 02.07.2025 8:38:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotZasilky](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdKonfigurace] [int] NULL,
	[KodDopravce] [nvarchar](20) NOT NULL,
	[service_type] [nvarchar](50) NULL,
	[branch_id] [nvarchar](100) NULL,
	[AccessPointUPS] [nvarchar](40) NULL,
	[rec_name] [nvarchar](255) NULL,
	[rec_firm] [nvarchar](255) NULL,
	[rec_phone] [nvarchar](50) NULL,
	[rec_email] [nvarchar](100) NULL,
	[rec_street] [nvarchar](100) NULL,
	[rec_street_append] [nvarchar](100) NULL,
	[rec_city] [nvarchar](100) NULL,
	[rec_zip] [nvarchar](20) NULL,
	[rec_region] [nvarchar](100) NULL,
	[rec_country] [nvarchar](100) NULL,
	[rec_id] [nvarchar](50) NULL,
	[rec_floor_number] [int] NULL,
	[bank_account_number] [nvarchar](50) NULL,
	[bank_code] [nvarchar](15) NULL,
	[neutralize] [bit] NOT NULL,
	[neutralize_account_number] [nvarchar](50) NULL,
	[neutralize_name] [nvarchar](255) NULL,
	[neutralize_firm] [nvarchar](255) NULL,
	[neutralize_phone] [nvarchar](50) NULL,
	[neutralize_email] [nvarchar](100) NULL,
	[neutralize_street] [nvarchar](100) NULL,
	[neutralize_city] [nvarchar](100) NULL,
	[neutralize_zip] [nvarchar](20) NULL,
	[neutralize_region] [nvarchar](100) NULL,
	[neutralize_country] [nvarchar](100) NULL,
	[IdDokladyZbozi] [int] NULL,
	[IdDOBJ] [int] NULL,
	[Dobirka] [bit] NOT NULL,
	[B2A] [bit] NOT NULL,
	[labels_url] [nvarchar](100) NULL,
	[customs_url] [nvarchar](100) NULL,
	[handover_url] [nvarchar](100) NULL,
	[DatumTiskuArchu] [datetime] NULL,
	[file_url] [nvarchar](100) NULL,
	[order_id] [nvarchar](10) NULL,
	[PoradoveCislo] [int] NOT NULL,
	[StitekVytisknut] [bit] NOT NULL,
	[Poznamka] [ntext] NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[Poznamka_255]  AS (substring(replace(substring([Poznamka],(1),(255)),nchar((13))+nchar((10)),nchar((32))),(1),(255))),
	[Poznamka_All]  AS ([Poznamka]),
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[DatPorizeni_V]  AS (datepart(iso_week,[DatPorizeni])),
	[DatPorizeni_O]  AS (((datepart(weekday,[DatPorizeni])+@@datefirst)-(2))%(7)+(1)),
 CONSTRAINT [PK__Tabx_BalikobotZasilky__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilky__rec_country]  DEFAULT ('CZ') FOR [rec_country]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilky__neutralize]  DEFAULT ((0)) FOR [neutralize]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilky__Dobirka]  DEFAULT ((0)) FOR [Dobirka]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilky__B2A]  DEFAULT ((0)) FOR [B2A]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilky__PoradoveCislo]  DEFAULT ((0)) FOR [PoradoveCislo]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilky__StitekVytisknut]  DEFAULT ((0)) FOR [StitekVytisknut]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilky__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] ADD  CONSTRAINT [DF__Tabx_BalikobotZasilky__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotZasilky__IdDOBJ] FOREIGN KEY([IdDOBJ])
REFERENCES [dbo].[TabDosleObjH02] ([ID])
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] CHECK CONSTRAINT [FK__Tabx_BalikobotZasilky__IdDOBJ]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotZasilky__IdDokladyZbozi] FOREIGN KEY([IdDokladyZbozi])
REFERENCES [dbo].[TabDokladyZbozi] ([ID])
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] CHECK CONSTRAINT [FK__Tabx_BalikobotZasilky__IdDokladyZbozi]
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotZasilky__IdKonfigurace] FOREIGN KEY([IdKonfigurace])
REFERENCES [dbo].[Tabx_BalikobotKonfigurace] ([ID])
GO

ALTER TABLE [dbo].[Tabx_BalikobotZasilky] CHECK CONSTRAINT [FK__Tabx_BalikobotZasilky__IdKonfigurace]
GO

