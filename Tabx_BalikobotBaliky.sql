USE [RayService]
GO

/****** Object:  Table [dbo].[Tabx_BalikobotBaliky]    Script Date: 02.07.2025 8:25:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabx_BalikobotBaliky](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GUID] [binary](16) NOT NULL,
	[IdZasilky] [int] NOT NULL,
	[OrderNumber] [int] NOT NULL,
	[Stav] [tinyint] NOT NULL,
	[carrier_id] [nvarchar](50) NULL,
	[package_id] [nvarchar](20) NULL,
	[price] [numeric](19, 6) NOT NULL,
	[ins_currency] [nvarchar](3) NULL,
	[ins_category] [nvarchar](3) NULL,
	[cod_price] [numeric](19, 6) NULL,
	[cod_currency] [nvarchar](3) NULL,
	[vs] [nvarchar](20) NULL,
	[real_order_id] [nvarchar](30) NULL,
	[services] [nvarchar](50) NULL,
	[width] [numeric](19, 6) NULL,
	[length] [numeric](19, 6) NULL,
	[loading_length_pallets] [numeric](19, 6) NULL,
	[loading_length] [numeric](19, 6) NULL,
	[height] [numeric](19, 6) NULL,
	[weight] [numeric](19, 6) NULL,
	[volume] [numeric](19, 6) NULL,
	[sms_notification] [bit] NOT NULL,
	[phone_notification] [bit] NOT NULL,
	[phone_delivery_notification] [bit] NOT NULL,
	[b2c_notification] [bit] NOT NULL,
	[credit_card] [bit] NOT NULL,
	[del_insurance] [bit] NOT NULL,
	[del_evening] [bit] NOT NULL,
	[get_piece_numbers] [bit] NOT NULL,
	[del_exworks] [tinyint] NOT NULL,
	[del_exworks_zip] [nvarchar](20) NULL,
	[require_full_age] [tinyint] NOT NULL,
	[password] [nvarchar](99) NULL,
	[full_age_data] [int] NULL,
	[label_url] [nvarchar](100) NULL,
	[customs_url] [nvarchar](100) NULL,
	[StitekVytisknut] [bit] NOT NULL,
	[TrackStatusCode] [int] NULL,
	[TrackStatusText] [nvarchar](255) NULL,
	[TrackLink] [nvarchar](400) NULL,
	[Poznamka] [ntext] NULL,
	[comfort_service] [bit] NOT NULL,
	[comfort_plus_service] [bit] NOT NULL,
	[app_disp] [bit] NOT NULL,
	[vdl_service] [bit] NOT NULL,
	[over_dimension] [bit] NOT NULL,
	[swap] [tinyint] NOT NULL,
	[wrap_back_count] [int] NULL,
	[wrap_back_note] [nvarchar](40) NULL,
	[note] [nvarchar](350) NULL,
	[note_driver] [nvarchar](62) NULL,
	[note_recipient] [nvarchar](62) NULL,
	[reference] [nvarchar](20) NULL,
	[mu_type_one] [nvarchar](50) NULL,
	[pieces_count_one] [int] NULL,
	[mu_type_two] [nvarchar](50) NULL,
	[pieces_count_two] [int] NULL,
	[mu_type_three] [nvarchar](50) NULL,
	[pieces_count_three] [int] NULL,
	[mu_type] [nvarchar](50) NULL,
	[pieces_count] [int] NULL,
	[delivery_date] [datetime] NULL,
	[adr_service] [bit] NOT NULL,
	[bank_account_number] [nvarchar](50) NULL,
	[content] [nvarchar](90) NULL,
	[terms_of_trade] [nvarchar](3) NULL,
	[terms_of_trade_location] [nvarchar](50) NULL,
	[invoice_pdf] [int] NULL,
	[invoice_type] [nvarchar](50) NULL,
	[swap_option] [tinyint] NULL,
	[DatumPredaniDat] [datetime] NULL,
	[DatumPredani] [datetime] NULL,
	[DatumTiskuStitku] [datetime] NULL,
	[email_notification] [bit] NOT NULL,
	[del_exworks_account_number] [nvarchar](100) NULL,
	[pickup_date] [datetime] NULL,
	[pickup_time_from] [datetime] NULL,
	[pickup_time_to] [datetime] NULL,
	[delivery_time_from] [datetime] NULL,
	[delivery_time_to] [datetime] NULL,
	[pieces] [nvarchar](1000) NULL,
	[carrier_id_swap] [nvarchar](50) NULL,
	[sm1_service] [bit] NOT NULL,
	[sm1_text] [nvarchar](160) NULL,
	[sm2_service] [bit] NOT NULL,
	[payer] [tinyint] NULL,
	[pickup_manipulation_cart] [bit] NOT NULL,
	[pickup_manipulation_lift] [bit] NOT NULL,
	[delivery_manipulation_cart] [bit] NOT NULL,
	[delivery_manipulation_lift] [bit] NOT NULL,
	[transform_temp_from] [numeric](19, 6) NULL,
	[transform_temp_to] [numeric](19, 6) NULL,
	[generate_invoice] [bit] NOT NULL,
	[Autor] [nvarchar](128) NOT NULL,
	[DatPorizeni] [datetime] NOT NULL,
	[Zmenil] [nvarchar](128) NULL,
	[DatZmeny] [datetime] NULL,
	[BlokovaniEditoru] [smallint] NULL,
	[GUIDText]  AS (CONVERT([nvarchar](36),CONVERT([uniqueidentifier],[GUID]))),
	[Poznamka_255]  AS (substring(replace(substring([Poznamka],(1),(255)),nchar((13))+nchar((10)),nchar((32))),(1),(255))),
	[Poznamka_All]  AS ([Poznamka]),
	[DatumPredaniDat_D]  AS (datepart(day,[DatumPredaniDat])),
	[DatumPredaniDat_M]  AS (datepart(month,[DatumPredaniDat])),
	[DatumPredaniDat_Y]  AS (datepart(year,[DatumPredaniDat])),
	[DatumPredaniDat_Q]  AS (datepart(quarter,[DatumPredaniDat])),
	[DatumPredaniDat_W]  AS (datepart(week,[DatumPredaniDat])),
	[DatumPredaniDat_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumPredaniDat])))),
	[DatumPredaniDat_V]  AS (datepart(iso_week,[DatumPredaniDat])),
	[DatumPredaniDat_O]  AS (((datepart(weekday,[DatumPredaniDat])+@@datefirst)-(2))%(7)+(1)),
	[DatumPredani_D]  AS (datepart(day,[DatumPredani])),
	[DatumPredani_M]  AS (datepart(month,[DatumPredani])),
	[DatumPredani_Y]  AS (datepart(year,[DatumPredani])),
	[DatumPredani_Q]  AS (datepart(quarter,[DatumPredani])),
	[DatumPredani_W]  AS (datepart(week,[DatumPredani])),
	[DatumPredani_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatumPredani])))),
	[DatumPredani_V]  AS (datepart(iso_week,[DatumPredani])),
	[DatumPredani_O]  AS (((datepart(weekday,[DatumPredani])+@@datefirst)-(2))%(7)+(1)),
	[DatPorizeni_D]  AS (datepart(day,[DatPorizeni])),
	[DatPorizeni_M]  AS (datepart(month,[DatPorizeni])),
	[DatPorizeni_Y]  AS (datepart(year,[DatPorizeni])),
	[DatPorizeni_Q]  AS (datepart(quarter,[DatPorizeni])),
	[DatPorizeni_W]  AS (datepart(week,[DatPorizeni])),
	[DatPorizeni_X]  AS (CONVERT([datetime],CONVERT([int],CONVERT([float],[DatPorizeni])))),
	[DatPorizeni_V]  AS (datepart(iso_week,[DatPorizeni])),
	[DatPorizeni_O]  AS (((datepart(weekday,[DatPorizeni])+@@datefirst)-(2))%(7)+(1)),
	[carrier_id_final] [nvarchar](50) NULL,
	[track_url_final] [nvarchar](400) NULL,
	[file_url] [nvarchar](400) NULL,
 CONSTRAINT [PK__Tabx_BalikobotBaliky__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__GUID]  DEFAULT (newid()) FOR [GUID]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__Stav]  DEFAULT ((0)) FOR [Stav]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__price]  DEFAULT ((0)) FOR [price]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__sms_notification]  DEFAULT ((0)) FOR [sms_notification]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__phone_notification]  DEFAULT ((0)) FOR [phone_notification]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__phone_delivery_notification]  DEFAULT ((0)) FOR [phone_delivery_notification]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__b2c_notification]  DEFAULT ((0)) FOR [b2c_notification]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__credit_card]  DEFAULT ((0)) FOR [credit_card]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__del_insurance]  DEFAULT ((0)) FOR [del_insurance]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__del_evening]  DEFAULT ((0)) FOR [del_evening]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__get_piece_numbers]  DEFAULT ((1)) FOR [get_piece_numbers]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__del_exworks]  DEFAULT ((0)) FOR [del_exworks]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__require_full_age]  DEFAULT ((0)) FOR [require_full_age]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__StitekVytisknut]  DEFAULT ((0)) FOR [StitekVytisknut]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__comfort_service]  DEFAULT ((0)) FOR [comfort_service]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__comfort_plus_service]  DEFAULT ((0)) FOR [comfort_plus_service]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__app_disp]  DEFAULT ((0)) FOR [app_disp]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__vdl_service]  DEFAULT ((0)) FOR [vdl_service]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__over_dimension]  DEFAULT ((0)) FOR [over_dimension]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__swap]  DEFAULT ((0)) FOR [swap]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__adr_service]  DEFAULT ((0)) FOR [adr_service]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__email_notification]  DEFAULT ((0)) FOR [email_notification]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__sm1_service]  DEFAULT ((0)) FOR [sm1_service]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__sm2_service]  DEFAULT ((0)) FOR [sm2_service]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__pickup_manipulation_cart]  DEFAULT ((0)) FOR [pickup_manipulation_cart]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__pickup_manipulation_lift]  DEFAULT ((0)) FOR [pickup_manipulation_lift]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__delivery_manipulation_cart]  DEFAULT ((0)) FOR [delivery_manipulation_cart]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__delivery_manipulation_lift]  DEFAULT ((0)) FOR [delivery_manipulation_lift]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__generate_invoice]  DEFAULT ((0)) FOR [generate_invoice]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__Autor]  DEFAULT (suser_sname()) FOR [Autor]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] ADD  CONSTRAINT [DF__Tabx_BalikobotBaliky__DatPorizeni]  DEFAULT (getdate()) FOR [DatPorizeni]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky]  WITH CHECK ADD  CONSTRAINT [FK__Tabx_BalikobotBaliky__IdZasilky] FOREIGN KEY([IdZasilky])
REFERENCES [dbo].[Tabx_BalikobotZasilky] ([ID])
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] CHECK CONSTRAINT [FK__Tabx_BalikobotBaliky__IdZasilky]
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky]  WITH CHECK ADD  CONSTRAINT [CK__Tabx_BalikobotBaliky__full_age_data] CHECK  (([full_age_data]>=(1900) AND [full_age_data]<=(2199)))
GO

ALTER TABLE [dbo].[Tabx_BalikobotBaliky] CHECK CONSTRAINT [CK__Tabx_BalikobotBaliky__full_age_data]
GO

