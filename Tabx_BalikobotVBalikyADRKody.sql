USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotVBalikyADRKody]    Script Date: 02.07.2025 8:36:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotVBalikyADRKody](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdBalik] [int] NOT NULL,
	[KodDopravce] [nvarchar](20) NULL,
	[ADR_unit_id] [nvarchar](20) NULL,
	[ADR_unit_pieces_count] [numeric](19, 6) NULL,
	[ADR_unit_weight] [numeric](19, 6) NULL,
	[ADR_unit_net_weight] [numeric](19, 6) NULL,
	[ADR_unit_volume] [numeric](19, 6) NULL,
	[ADR_manipulation_unit] [nvarchar](50) NULL,
	[adr_eu_waste_code] [nvarchar](10) NULL,
	[adr_expected_quantities] [bit] NOT NULL,
	[adr_label_type] [nvarchar](10) NULL,
	[adr_limited_quantity] [bit] NOT NULL,
	[adr_marine_pollutant] [bit] NOT NULL,
	[adr_package_group] [nvarchar](4) NULL,
	[adr_pieces_count] [int] NULL,
	[adr_shipping_name] [nvarchar](250) NULL,
	[adr_special_provision] [nvarchar](250) NULL,
	[adr_technical_name] [nvarchar](250) NULL,
	[adr_tunnel_code] [nvarchar](10) NULL,
	[adr_waste] [bit] NOT NULL,
	[adr_weight_type] [nvarchar](10) NULL,
	[adr_description] [nvarchar](4000) NULL,
	[adr_quantity] [numeric](19, 6) NULL,
	[adr_exempted_quantity] [bit] NOT NULL,
	[adr_is_empty] [bit] NOT NULL,
	[adr_environmental_indicator] [bit] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
 CONSTRAINT [PK__Tabx_BalikobotVBalikyADRKody__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__adr_expected_quantities]  DEFAULT ((0)) FOR [adr_expected_quantities]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__adr_limited_quantity]  DEFAULT ((0)) FOR [adr_limited_quantity]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__adr_marine_pollutant]  DEFAULT ((0)) FOR [adr_marine_pollutant]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__adr_waste]  DEFAULT ((0)) FOR [adr_waste]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__adr_exempted_quantity]  DEFAULT ((0)) FOR [adr_exempted_quantity]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__adr_is_empty]  DEFAULT ((0)) FOR [adr_is_empty]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__adr_environmental_indicator]  DEFAULT ((0)) FOR [adr_environmental_indicator]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] ADD  CONSTRAINT [DF__Tabx_BalikobotVBalikyADRKody__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotVBalikyADRKody__IdBalik] FOREIGN KEY([IdBalik])
REFERENCES [dbo].[Tabx_BalikobotBaliky] ([ID])
GO

ALTER TABLE [dbo].[Tabx_BalikobotVBalikyADRKody] CHECK CONSTRAINT [FK__Tabx_BalikobotVBalikyADRKody__IdBalik]
GO

